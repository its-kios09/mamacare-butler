import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mamacare_flutter/models/user.dart';
import 'package:mamacare_flutter/services/storage_service.dart';
import 'package:mamacare_flutter/main.dart';

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

    if (kDebugMode) {
      print('🔑 Stored hash: $storedHash');
    }

    if (storedHash == null) {
      if (kDebugMode) {
        print('❌ No PIN hash found in storage');
      }
      return false;
    }

    final enteredHash = hashPin(pin);

    if (kDebugMode) {
      print('🔑 Entered hash: $enteredHash');
      print('🔑 Match: ${storedHash == enteredHash}');
    }

    return storedHash == enteredHash;
  }

  Future<bool> setupPin(String phoneNumber, String pin) async {
    try {
      if (kDebugMode) {
        print('📝 Setting up PIN for: $phoneNumber');
      }

      // 1. Register user on backend
      final response = await client.v1Auth.registerUser(phoneNumber);

      // 2. Check if registration succeeded
      if (!response.success) {
        if (kDebugMode) {
          print('❌ Registration failed: ${response.error?.message}');
        }
        return false;
      }

      // 3. Backend registration successful
      if (kDebugMode) {
        print('✅ User registered on backend: ${response.user?.phoneNumber}');
        print('✅ User ID: ${response.user?.id}');
      }

      // 4. Save PIN locally
      final pinHash = hashPin(pin);
      await _storage.savePinHash(pinHash);

      // 5. Save phone number
      await _storage.savePhoneNumber(phoneNumber);

      // 6. Save user ID from backend response
      if (response.user?.id != null) {
        await _storage.saveUserId(response.user!.id!);
        if (kDebugMode) {
          print('✅ User ID saved: ${response.user!.id}');
        }
      }

      // 7. Generate and save auth token
      final token = _generateToken(phoneNumber);
      await _storage.saveAuthToken(token);

      if (kDebugMode) {
        print('✅ Setup complete!');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Setup PIN failed: $e');
      }
      return false;
    }
  }

  Future<bool> loginWithPin(String pin) async {
    try {
      final isValid = await verifyPin(pin);

      if (kDebugMode) {
        print('🔐 PIN verification: $isValid');
      }

      if (isValid) {
        final phone = await _storage.getPhoneNumber();
        final userId = _storage.getUserId();

        if (kDebugMode) {
          print('📞 Stored phone: $phone');
          print('🆔 Stored user ID: $userId');
        }

        if (phone != null && userId != null) {
          _currentUser = User(
            id: userId,
            phoneNumber: phone,
            name: 'User',
            createdAt: DateTime.now(),
          );

          if (kDebugMode) {
            print('✅ Login successful');
          }

          return true;
        }
      }

      if (kDebugMode) {
        print('❌ Login failed');
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
      }
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
        final userId = _storage.getUserId();

        if (phone != null && userId != null) {
          _currentUser = User(
            id: userId,
            phoneNumber: phone,
            name: 'User',
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