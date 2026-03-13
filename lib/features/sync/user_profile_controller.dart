import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/presentation/controllers/auth_controller.dart';
import 'cloud_sync_controller.dart';

class UserProfileState {
  final String? fcmToken;

  const UserProfileState({required this.fcmToken});
}

final userProfileProvider =
    StateNotifierProvider<UserProfileController, UserProfileState>(
  (ref) => UserProfileController(ref),
);

class UserProfileController extends StateNotifier<UserProfileState> {
  final Ref _ref;
  UserProfileController(this._ref)
      : super(const UserProfileState(fcmToken: null)) {
    _ref.listen(authStateProvider, (prev, next) {
      next.whenData((user) async {
        if (user == null) return;
        // Try to load profile data.
        final doc = _ref
            .read(firestoreProvider)
            .collection('users')
            .doc(user.uid)
            .collection('data')
            .doc('profile');
        final snap = await doc.get();
        state = UserProfileState(
          fcmToken: snap.data()?['fcmToken'] as String?,
        );
      });
    });
  }

  Future<void> saveFcmToken(String token) async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    final doc = _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('data')
        .doc('profile');

    await doc.set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    state = UserProfileState(fcmToken: token);
  }
}
