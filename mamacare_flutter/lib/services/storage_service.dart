import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Initialize
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage (for sensitive data)
  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // Regular Storage (for non-sensitive data)
  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  // Auth-specific helpers
  Future<void> saveAuthToken(String token) async {
    await saveSecure('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    return await readSecure('auth_token');
  }

  Future<void> savePinHash(String pinHash) async {
    await saveSecure('pin_hash', pinHash);
  }

  Future<String?> getPinHash() async {
    return await readSecure('pin_hash');
  }

  Future<void> savePhoneNumber(String phone) async {
    await saveString('phone_number', phone);
  }

  String? getPhoneNumber() {
    return getString('phone_number');
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    await saveBool('biometric_enabled', enabled);
  }

  bool getBiometricEnabled() {
    return getBool('biometric_enabled') ?? false;
  }

  Future<void> logout() async {
    await clearSecure();
    await clear();
  }
}