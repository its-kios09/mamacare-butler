/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:mamacare_client/src/protocol/auth_response.dart' as _i5;
import 'package:mamacare_client/src/protocol/user.dart' as _i6;
import 'package:mamacare_client/src/protocol/kick_session.dart' as _i7;
import 'package:mamacare_client/src/protocol/maternal_profile.dart' as _i8;
import 'package:mamacare_client/src/protocol/ultrasound_scan.dart' as _i9;
import 'package:mamacare_client/src/protocol/greetings/greeting.dart' as _i10;
import 'protocol.dart' as _i11;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointV1Auth extends _i2.EndpointRef {
  EndpointV1Auth(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'v1Auth';

  _i3.Future<_i5.AuthResponse> registerUser(String phoneNumber) =>
      caller.callServerEndpoint<_i5.AuthResponse>(
        'v1Auth',
        'registerUser',
        {'phoneNumber': phoneNumber},
      );

  _i3.Future<_i6.User?> getUserByPhone(String phoneNumber) =>
      caller.callServerEndpoint<_i6.User?>(
        'v1Auth',
        'getUserByPhone',
        {'phoneNumber': phoneNumber},
      );

  _i3.Future<bool> userExists(String phoneNumber) =>
      caller.callServerEndpoint<bool>(
        'v1Auth',
        'userExists',
        {'phoneNumber': phoneNumber},
      );
}

/// {@category Endpoint}
class EndpointV1KickCounter extends _i2.EndpointRef {
  EndpointV1KickCounter(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'v1KickCounter';

  /// Save a kick counting session
  _i3.Future<_i7.KickSession?> saveKickSession(
    int userId,
    int kickCount,
    int durationMinutes,
    String? notes,
  ) => caller.callServerEndpoint<_i7.KickSession?>(
    'v1KickCounter',
    'saveKickSession',
    {
      'userId': userId,
      'kickCount': kickCount,
      'durationMinutes': durationMinutes,
      'notes': notes,
    },
  );

  /// Get recent kick sessions for a user
  _i3.Future<List<_i7.KickSession>> getRecentKicks(
    int userId,
    int days,
  ) => caller.callServerEndpoint<List<_i7.KickSession>>(
    'v1KickCounter',
    'getRecentKicks',
    {
      'userId': userId,
      'days': days,
    },
  );

  /// Get kick statistics for a user
  _i3.Future<Map<String, dynamic>> getKickStats(
    int userId,
    int days,
  ) => caller.callServerEndpoint<Map<String, dynamic>>(
    'v1KickCounter',
    'getKickStats',
    {
      'userId': userId,
      'days': days,
    },
  );

  /// Get AI-powered kick pattern analysis using Gemini
  _i3.Future<String> getAIInsight(
    int userId,
    int pregnancyWeek,
  ) => caller.callServerEndpoint<String>(
    'v1KickCounter',
    'getAIInsight',
    {
      'userId': userId,
      'pregnancyWeek': pregnancyWeek,
    },
  );
}

/// {@category Endpoint}
class EndpointV1MaternalProfile extends _i2.EndpointRef {
  EndpointV1MaternalProfile(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'v1MaternalProfile';

  /// Create or update maternal profile
  _i3.Future<_i8.MaternalProfile?> saveProfile(
    int userId,
    String fullName,
    DateTime expectedDueDate,
    DateTime? lastMenstrualPeriod,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? emergencyContact,
    String? emergencyPhone,
  ) => caller.callServerEndpoint<_i8.MaternalProfile?>(
    'v1MaternalProfile',
    'saveProfile',
    {
      'userId': userId,
      'fullName': fullName,
      'expectedDueDate': expectedDueDate,
      'lastMenstrualPeriod': lastMenstrualPeriod,
      'bloodType': bloodType,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
    },
  );

  /// Get maternal profile by user ID
  _i3.Future<_i8.MaternalProfile?> getProfile(int userId) =>
      caller.callServerEndpoint<_i8.MaternalProfile?>(
        'v1MaternalProfile',
        'getProfile',
        {'userId': userId},
      );
}

/// {@category Endpoint}
class EndpointV1Ultrasound extends _i2.EndpointRef {
  EndpointV1Ultrasound(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'v1Ultrasound';

  /// Analyze ultrasound image with Gemini Vision
  _i3.Future<Map<String, dynamic>> analyzeUltrasound(
    int userId,
    String imageBase64,
    int pregnancyWeek,
  ) => caller.callServerEndpoint<Map<String, dynamic>>(
    'v1Ultrasound',
    'analyzeUltrasound',
    {
      'userId': userId,
      'imageBase64': imageBase64,
      'pregnancyWeek': pregnancyWeek,
    },
  );

  /// Save ultrasound scan record
  _i3.Future<_i9.UltrasoundScan?> saveUltrasoundScan(
    int userId,
    int pregnancyWeek,
    String imageBase64,
    String measurements,
    String aiExplanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
  ) => caller.callServerEndpoint<_i9.UltrasoundScan?>(
    'v1Ultrasound',
    'saveUltrasoundScan',
    {
      'userId': userId,
      'pregnancyWeek': pregnancyWeek,
      'imageBase64': imageBase64,
      'measurements': measurements,
      'aiExplanation': aiExplanation,
      'nextScanWeek': nextScanWeek,
      'nextScanDate': nextScanDate,
    },
  );

  /// Get user's ultrasound history
  _i3.Future<List<_i9.UltrasoundScan>> getUserScans(int userId) =>
      caller.callServerEndpoint<List<_i9.UltrasoundScan>>(
        'v1Ultrasound',
        'getUserScans',
        {'userId': userId},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i10.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i10.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i11.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    v1Auth = EndpointV1Auth(this);
    v1KickCounter = EndpointV1KickCounter(this);
    v1MaternalProfile = EndpointV1MaternalProfile(this);
    v1Ultrasound = EndpointV1Ultrasound(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointV1Auth v1Auth;

  late final EndpointV1KickCounter v1KickCounter;

  late final EndpointV1MaternalProfile v1MaternalProfile;

  late final EndpointV1Ultrasound v1Ultrasound;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'v1Auth': v1Auth,
    'v1KickCounter': v1KickCounter,
    'v1MaternalProfile': v1MaternalProfile,
    'v1Ultrasound': v1Ultrasound,
    'greeting': greeting,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
