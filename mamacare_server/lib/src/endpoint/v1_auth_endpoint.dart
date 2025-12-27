import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// V1 Authentication Endpoint
class V1AuthEndpoint extends Endpoint {
  /// Register user with phone number
  Future<AuthResponse> registerUser(Session session, String phoneNumber) async {
    // Validate phone number
    final validationError = _validatePhoneNumber(phoneNumber);
    if (validationError != null) {
      session.log('Invalid phone: $validationError', level: LogLevel.warning);
      return AuthResponse(
        success: false,
        error: AuthException(
          message: validationError,
          code: 'INVALID_PHONE',
          statusCode: 400,
        ),
      );
    }

    final normalizedPhone = _normalizePhoneNumber(phoneNumber);

    try {
      // Check if user already exists
      final existingUser = await User.db.findFirstRow(
        session,
        where: (t) => t.phoneNumber.equals(normalizedPhone),
      );

      if (existingUser != null) {
        session.log('User already exists: ${existingUser.phoneNumber}');
        return AuthResponse(
          success: true,
          user: existingUser,
        );
      }

      // Create new user
      final user = User(
        phoneNumber: normalizedPhone,
        createdAt: DateTime.now(),
      );

      final insertedUser = await User.db.insertRow(session, user);

      session.log(
        'New user registered: ${insertedUser.phoneNumber}, ID: ${insertedUser.id}',
      );

      return AuthResponse(
        success: true,
        user: insertedUser,
      );
    } catch (e) {
      session.log('Database error: $e', level: LogLevel.error);
      return AuthResponse(
        success: false,
        error: AuthException(
          message: 'Failed to register user. Please try again.',
          code: 'DATABASE_ERROR',
          statusCode: 500,
        ),
      );
    }
  }

  /// Get user by phone number
  Future<User?> getUserByPhone(Session session, String phoneNumber) async {
    final validationError = _validatePhoneNumber(phoneNumber);
    if (validationError != null) {
      session.log('Invalid phone: $validationError', level: LogLevel.warning);
      return null;
    }

    final normalizedPhone = _normalizePhoneNumber(phoneNumber);

    try {
      final user = await User.db.findFirstRow(
        session,
        where: (t) => t.phoneNumber.equals(normalizedPhone),
      );

      if (user != null) {
        session.log('User found: ${user.phoneNumber}, ID: ${user.id}');
      } else {
        session.log('User not found: $normalizedPhone');
      }

      return user;
    } catch (e) {
      session.log('Database error: $e', level: LogLevel.error);
      return null;
    }
  }

  // Validation
  String? _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }

    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 9) {
      return 'Phone number is too short';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }

    if (!digitsOnly.startsWith('254') &&
        !digitsOnly.startsWith('0') &&
        !digitsOnly.startsWith('7') &&
        !digitsOnly.startsWith('1')) {
      return 'Invalid phone number format for Kenya';
    }

    return null;
  }

  String _normalizePhoneNumber(String phoneNumber) {
    String digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (!digits.startsWith('254')) {
      digits = '254$digits';
    }

    return '+$digits';
  }
}
