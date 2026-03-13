import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import '../core/data/local_storage.dart';

class CloudSyncState {
  final bool syncing;
  final bool pending;
  final DateTime? lastSyncedAt;
  final String? lastError;

  const CloudSyncState({
    required this.syncing,
    required this.pending,
    required this.lastSyncedAt,
    required this.lastError,
  });

  CloudSyncState copyWith({
    bool? syncing,
    bool? pending,
    DateTime? lastSyncedAt,
    String? lastError,
  }) {
    return CloudSyncState(
      syncing: syncing ?? this.syncing,
      pending: pending ?? this.pending,
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
  CloudSyncController(this._ref)
      : super(const CloudSyncState(
          syncing: false,
          pending: false,
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

  Future<void> pullThenMaybePush(User user) async {
    final pending = await LocalStorage.loadCloudPending();
    state = state.copyWith(syncing: true, pending: pending, lastError: null);
    try {
      final snap = await _doc(user).get();
      if (!snap.exists) {
        // First time: push local.
        await pushFromLocal(user);
        state = state.copyWith(syncing: false);
        return;
      }

      final remoteUpdatedAt = (snap.data()?['updatedAt'] as Timestamp?)?.toDate();
      final remoteData = snap.data()?['data'] as Map<String, dynamic>?;

      if (remoteData == null) {
        await pushFromLocal(user);
        state = state.copyWith(syncing: false);
        return;
      }

      final localIso = await LocalStorage.loadCloudUpdatedAt();
      final localUpdated = localIso == null ? null : DateTime.tryParse(localIso);

      if (remoteUpdatedAt != null &&
          (localUpdated == null || remoteUpdatedAt.isAfter(localUpdated))) {
        await LocalStorage.importAll(remoteData);
        await LocalStorage.saveCloudUpdatedAt(remoteUpdatedAt.toIso8601String());
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
