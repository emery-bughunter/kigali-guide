import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// Wraps Firebase Authentication operations
// ---------------------------------------------------------------------------

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of Firebase auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in Firebase user (nullable).
  User? get currentUser => _auth.currentUser;

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _toAppUser(credential.user);
  }

  Future<AppUser?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(displayName.trim());

      // Persist user profile in Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set({
            'uid': credential.user!.uid,
            'email': email.trim(),
            'displayName': displayName.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    }

    return _toAppUser(credential.user);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
