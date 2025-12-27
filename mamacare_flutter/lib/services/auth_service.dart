import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mamacare_flutter/models/user.dart';
import 'package:mamacare_flutter/services/storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAuthToken();
    return token != null;
  }

  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.getPinHash();
    if (storedHash == null) return false;

    final enteredHash = hashPin(pin);
    return storedHash == enteredHash;
  }

  Future<bool> setupPin(String phoneNumber, String pin) async {
    try {
      final pinHash = hashPin(pin);
      await _storage.savePinHash(pinHash);
      await _storage.savePhoneNumber(phoneNumber);

      final token = _generateToken(phoneNumber);
      await _storage.saveAuthToken(token);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginWithPin(String pin) async {
    try {
      final isValid = await verifyPin(pin);

      if (isValid) {
        final phone = _storage.getPhoneNumber();
        if (phone != null) {
          _currentUser = User(
            id: 1,
            phoneNumber: phone,
            name: 'Test User',
            createdAt: DateTime.now(),
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get biometrics failed: $e');
      }
      return [];
    }
  }

  Future<bool> enableBiometric() async {
    try {
      final canUse = await canUseBiometric();
      if (!canUse) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric login for MamaCare',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        await _storage.saveBiometricEnabled(true);
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Enable biometric failed: $e');
      }
      return false;
    }
  }

  // Login with biometric
  Future<bool> loginWithBiometric() async {
    try {
      final isEnabled = _storage.getBiometricEnabled();
      if (!isEnabled) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Login to MamaCare',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        final phone = _storage.getPhoneNumber();
        if (phone != null) {
          // Load user data
          _currentUser = User(
            id: 1,
            phoneNumber: phone,
            name: 'Test User',
            createdAt: DateTime.now(),
          );

          if (kDebugMode) {
            print('✅ Biometric login successful');
          }
          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Biometric login failed: $e');
      }
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    await _storage.logout();

    if (kDebugMode) {
      print('✅ Logged out');
    }
  }

  String _generateToken(String phoneNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$phoneNumber:$timestamp';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Change PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final isValid = await verifyPin(oldPin);
      if (!isValid) return false;

      final newHash = hashPin(newPin);
      await _storage.savePinHash(newHash);

      if (kDebugMode) {
        print('✅ PIN changed successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Change PIN failed: $e');
      }
      return false;
    }
  }
}