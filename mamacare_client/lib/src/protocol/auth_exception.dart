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

abstract class AuthException implements _i1.SerializableModel {
  AuthException._({
    required this.message,
    required this.code,
    required this.statusCode,
  });

  factory AuthException({
    required String message,
    required String code,
    required int statusCode,
  }) = _AuthExceptionImpl;

  factory AuthException.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuthException(
      message: jsonSerialization['message'] as String,
      code: jsonSerialization['code'] as String,
      statusCode: jsonSerialization['statusCode'] as int,
    );
  }

  String message;

  String code;

  int statusCode;

  /// Returns a shallow copy of this [AuthException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthException copyWith({
    String? message,
    String? code,
    int? statusCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuthException',
      'message': message,
      'code': code,
      'statusCode': statusCode,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AuthExceptionImpl extends AuthException {
  _AuthExceptionImpl({
    required String message,
    required String code,
    required int statusCode,
  }) : super._(
         message: message,
         code: code,
         statusCode: statusCode,
       );

  /// Returns a shallow copy of this [AuthException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthException copyWith({
    String? message,
    String? code,
    int? statusCode,
  }) {
    return AuthException(
      message: message ?? this.message,
      code: code ?? this.code,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}
