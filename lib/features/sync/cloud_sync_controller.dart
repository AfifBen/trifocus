import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import '../core/data/local_storage.dart';

class CloudSyncState {
  final bool syncing;
  final String? lastError;

  const CloudSyncState({required this.syncing, required this.lastError});

  CloudSyncState copyWith({bool? syncing, String? lastError}) {
    return CloudSyncState(
      syncing: syncing ?? this.syncing,
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
      : super(const CloudSyncState(syncing: false, lastError: null)) {
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
    state = state.copyWith(syncing: true, lastError: null);
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

      if (remoteUpdatedAt != null && (localUpdated == null || remoteUpdatedAt.isAfter(localUpdated))) {
        await LocalStorage.importAll(remoteData);
        await LocalStorage.saveCloudUpdatedAt(remoteUpdatedAt.toIso8601String());
      }

      state = state.copyWith(syncing: false);
    } catch (e) {
      state = state.copyWith(syncing: false, lastError: e.toString());
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

      // Store a local timestamp to compare with remote on next login.
      await LocalStorage.saveCloudUpdatedAt(DateTime.now().toIso8601String());
      state = state.copyWith(syncing: false);
    } catch (e) {
      state = state.copyWith(syncing: false, lastError: e.toString());
    }
  }

  Future<void> pushIfSignedIn() async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;
    await pushFromLocal(user);
  }
}
