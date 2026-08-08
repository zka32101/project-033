import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorageService
///
/// Manages secure storage of sensitive data like authentication tokens,
/// API keys, and company/employee credentials using platform-native secure storage:
/// - iOS: Keychain
/// - Android: Keystore
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Token keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  // User/Company credentials
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';
  static const String _companyIdKey = 'company_id';
  static const String _invitationCodeKey = 'invitation_code';

  // Firebase custom token
  static const String _firebaseCustomTokenKey = 'firebase_custom_token';

  /// Save authentication token
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  /// Retrieve authentication token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Retrieve user email
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Save company ID
  static Future<void> saveCompanyId(String companyId) async {
    await _storage.write(key: _companyIdKey, value: companyId);
  }

  /// Retrieve company ID
  static Future<String?> getCompanyId() async {
    return await _storage.read(key: _companyIdKey);
  }

  /// Save invitation code for employee joining
  static Future<void> saveInvitationCode(String invitationCode) async {
    await _storage.write(key: _invitationCodeKey, value: invitationCode);
  }

  /// Retrieve invitation code
  static Future<String?> getInvitationCode() async {
    return await _storage.read(key: _invitationCodeKey);
  }

  /// Save Firebase custom token
  static Future<void> saveFirebaseCustomToken(String token) async {
    await _storage.write(key: _firebaseCustomTokenKey, value: token);
  }

  /// Retrieve Firebase custom token
  static Future<String?> getFirebaseCustomToken() async {
    return await _storage.read(key: _firebaseCustomTokenKey);
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear specific token
  static Future<void> clearAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  /// Delete all keys (complete logout)
  static Future<void> clearAllKeys() async {
    final allKeys = [
      _authTokenKey,
      _refreshTokenKey,
      _userEmailKey,
      _userPasswordKey,
      _companyIdKey,
      _invitationCodeKey,
      _firebaseCustomTokenKey,
    ];

    for (final key in allKeys) {
      await _storage.delete(key: key);
    }
  }
}
