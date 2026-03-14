import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import '../core/data/local_storage.dart';

class CloudSyncState {
  final bool syncing;
  final bool pending;
  final bool conflict;
  final DateTime? lastSyncedAt;
  final String? lastError;

  const CloudSyncState({
    required this.syncing,
    required this.pending,
    required this.conflict,
    required this.lastSyncedAt,
    required this.lastError,
  });

  CloudSyncState copyWith({
    bool? syncing,
    bool? pending,
    bool? conflict,
    DateTime? lastSyncedAt,
    String? lastError,
  }) {
    return CloudSyncState(
      syncing: syncing ?? this.syncing,
      pending: pending ?? this.pending,
      conflict: conflict ?? this.conflict,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: lastError,
    );
  }
}

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final cloudSyncProvider = StateNotifierProvider<CloudSyncController, CloudSyncState>(
  (ref) => CloudSyncController(ref),
);

class CloudSyncController extends StateNotifier<CloudSyncState> {
  final Ref _ref;

  Map<String, dynamic> _mergeNonNull(
    Map<String, dynamic> remote,
    Map<String, dynamic> local,
  ) {
    final merged = Map<String, dynamic>.from(local);
    remote.forEach((key, value) {
      if (value != null) merged[key] = value;
    });
    return merged;
  }

  CloudSyncController(this._ref)
      : super(const CloudSyncState(
          syncing: false,
          pending: false,
          conflict: false,
          lastSyncedAt: null,
          lastError: null,
        )) {
    _ref.listen(authStateProvider, (prev, next) {
      next.whenData((user) {
        if (user != null) {
          pullThenMaybePush(user);
        }
      });
    });
  }

  DocumentReference<Map<String, dynamic>> _doc(User user) {
    return _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('data')
        .doc('backup');
  }

  Map<String, dynamic>? _remoteBackupCache;
  DateTime? _remoteUpdatedAtCache;

  Future<void> pullThenMaybePush(User user) async {
    final pending = await LocalStorage.loadCloudPending();
    state = state.copyWith(
      syncing: true,
      pending: pending,
      conflict: false,
      lastError: null,
    );
    try {
      final snap = await _doc(user).get();
      if (!snap.exists) {
        // First time: push local.
        await pushFromLocal(user);
        state = state.copyWith(syncing: false);
        return;
      }

      final remoteUpdatedAt =
          (snap.data()?['updatedAt'] as Timestamp?)?.toDate();
      final remoteData = snap.data()?['data'] as Map<String, dynamic>?;

      if (remoteData == null) {
        await pushFromLocal(user);
        state = state.copyWith(syncing: false);
        return;
      }

      _remoteBackupCache = remoteData;
      _remoteUpdatedAtCache = remoteUpdatedAt;

      final localIso = await LocalStorage.loadCloudUpdatedAt();
      final localUpdated = localIso == null ? null : DateTime.tryParse(localIso);

      final remoteIsNewer = remoteUpdatedAt != null &&
          (localUpdated == null || remoteUpdatedAt.isAfter(localUpdated));

      // Conflict: local has pending changes but remote is newer.
      if (pending && remoteIsNewer) {
        state = state.copyWith(syncing: false, conflict: true);
        return;
      }

      if (remoteIsNewer) {
        // Merge strategy: never overwrite local values with nulls coming from
        // cloud backups (older versions or partial payloads). This prevents
        // wiping data like focusLogs.
        final local = await LocalStorage.exportAll();
        final merged = _mergeNonNull(remoteData, local);

        await LocalStorage.importAll(merged);
        await LocalStorage.saveCloudUpdatedAt(remoteUpdatedAt!.toIso8601String());
        await LocalStorage.saveCloudPending(false);
        state = state.copyWith(
          pending: false,
          lastSyncedAt: DateTime.now(),
        );
      }

      state = state.copyWith(syncing: false);
    } catch (e) {
      await LocalStorage.saveCloudPending(true);
      state = state.copyWith(
        syncing: false,
        pending: true,
        lastError: e.toString(),
      );
    }
  }

  Future<void> useCloudVersion() async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;
    final data = _remoteBackupCache;
    final updatedAt = _remoteUpdatedAtCache;
    if (data == null || updatedAt == null) return;

    state = state.copyWith(syncing: true, lastError: null);

    final local = await LocalStorage.exportAll();
    final merged = _mergeNonNull(data, local);

    await LocalStorage.importAll(merged);
    await LocalStorage.saveCloudUpdatedAt(updatedAt.toIso8601String());
    await LocalStorage.saveCloudPending(false);
    state = state.copyWith(
      syncing: false,
      pending: false,
      conflict: false,
      lastSyncedAt: DateTime.now(),
    );
  }

  Future<void> keepLocalVersion() async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;
    await pushFromLocal(user);
    state = state.copyWith(conflict: false);
  }

  Future<void> pushFromLocal(User user) async {
    state = state.copyWith(syncing: true, lastError: null);
    try {
      final data = await LocalStorage.exportAll();
      await _doc(user).set({
        'updatedAt': FieldValue.serverTimestamp(),
        'data': data,
      }, SetOptions(merge: true));

      // Read back server timestamp for accurate compare.
      final snap = await _doc(user).get();
      final remoteUpdatedAt =
          (snap.data()?['updatedAt'] as Timestamp?)?.toDate();

      if (remoteUpdatedAt != null) {
        await LocalStorage.saveCloudUpdatedAt(remoteUpdatedAt.toIso8601String());
      } else {
        await LocalStorage.saveCloudUpdatedAt(DateTime.now().toIso8601String());
      }

      await LocalStorage.saveCloudPending(false);

      state = state.copyWith(
        syncing: false,
        pending: false,
        lastSyncedAt: DateTime.now(),
      );
    } catch (e) {
      await LocalStorage.saveCloudPending(true);
      state = state.copyWith(
        syncing: false,
        pending: true,
        lastError: e.toString(),
      );
    }
  }

  Future<void> pushIfSignedIn() async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;
    await pushFromLocal(user);
  }
}
