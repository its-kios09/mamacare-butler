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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'user.dart' as _i2;
import 'auth_exception.dart' as _i3;
import 'package:mamacare_client/src/protocol/protocol.dart' as _i4;

abstract class AuthResponse implements _i1.SerializableModel {
  AuthResponse._({
    this.user,
    this.error,
    required this.success,
  });

  factory AuthResponse({
    _i2.User? user,
    _i3.AuthException? error,
    required bool success,
  }) = _AuthResponseImpl;

  factory AuthResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuthResponse(
      user: jsonSerialization['user'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.User>(jsonSerialization['user']),
      error: jsonSerialization['error'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.AuthException>(
              jsonSerialization['error'],
            ),
      success: jsonSerialization['success'] as bool,
    );
  }

  _i2.User? user;

  _i3.AuthException? error;

  bool success;

  /// Returns a shallow copy of this [AuthResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthResponse copyWith({
    _i2.User? user,
    _i3.AuthException? error,
    bool? success,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuthResponse',
      if (user != null) 'user': user?.toJson(),
      if (error != null) 'error': error?.toJson(),
      'success': success,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuthResponseImpl extends AuthResponse {
  _AuthResponseImpl({
    _i2.User? user,
    _i3.AuthException? error,
    required bool success,
  }) : super._(
         user: user,
         error: error,
         success: success,
       );

  /// Returns a shallow copy of this [AuthResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthResponse copyWith({
    Object? user = _Undefined,
    Object? error = _Undefined,
    bool? success,
  }) {
    return AuthResponse(
      user: user is _i2.User? ? user : this.user?.copyWith(),
      error: error is _i3.AuthException? ? error : this.error?.copyWith(),
      success: success ?? this.success,
    );
  }
}
