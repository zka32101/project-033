import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'secure_storage_service.dart';

/// AuthService for Anzet
///
/// Manages user authentication for both employees and admins,
/// with secure token storage and Firestore user profiles.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        // Save email and token securely
        await SecureStorageService.saveUserEmail(email);
        final token = await user.getIdToken();
        if (token != null) {
          await SecureStorageService.saveAuthToken(token);
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Email sign-in failed: $e');
      rethrow;
    }
  }

  /// Create account with email and password
  Future<User?> createAccountWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        // Save email and token securely
        await SecureStorageService.saveUserEmail(email);
        final token = await user.getIdToken();
        if (token != null) {
          await SecureStorageService.saveAuthToken(token);
        }

        // Create user profile in Firestore
        await _createUserProfile(user.uid, email);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Account creation failed: $e');
      rethrow;
    }
  }

  /// Sign in with invitation code (employee joining company)
  Future<User?> signInWithInvitationCode(
    String email,
    String password,
    String invitationCode,
  ) async {
    try {
      // Verify invitation code exists and matches company
      final inviteDoc = await _firestore
          .collection('invitations')
          .doc(invitationCode)
          .get();

      if (!inviteDoc.exists) {
        throw Exception('招待コードが無効です。');
      }

      final inviteData = inviteDoc.data() as Map<String, dynamic>;
      final companyId = inviteData['companyId'] as String?;

      if (companyId == null) {
        throw Exception('招待コード情報が不完全です。');
      }

      // Create account
      final user = await createAccountWithEmail(email, password);

      if (user != null) {
        // Save company ID and invitation code
        await SecureStorageService.saveCompanyId(companyId);
        await SecureStorageService.saveInvitationCode(invitationCode);

        // Create employee record
        await _firestore.collection('employees').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'companyId': companyId,
          'joinedAt': FieldValue.serverTimestamp(),
          'role': 'employee',
          'status': 'active',
        });

        // Mark invitation as used
        await _firestore
            .collection('invitations')
            .doc(invitationCode)
            .update({
          'usedBy': user.uid,
          'usedAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print('Sign in with invitation failed: $e');
      rethrow;
    }
  }

  /// Create user profile in Firestore
  Future<void> _createUserProfile(String uid, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to create user profile: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Clear secure storage on logout
      await SecureStorageService.clearAll();
    } catch (e) {
      print('Failed to sign out: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        // Clear secure storage
        await SecureStorageService.clearAll();
      }
    } catch (e) {
      print('Failed to delete account: $e');
      rethrow;
    }
  }
}
