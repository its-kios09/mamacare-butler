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
import 'auth_exception.dart' as _i2;
import 'auth_response.dart' as _i3;
import 'greetings/greeting.dart' as _i4;
import 'health_checkin.dart' as _i5;
import 'kick_session.dart' as _i6;
import 'maternal_profile.dart' as _i7;
import 'medication.dart' as _i8;
import 'ultrasound_analysis_result.dart' as _i9;
import 'ultrasound_scan.dart' as _i10;
import 'user.dart' as _i11;
import 'package:mamacare_client/src/protocol/health_checkin.dart' as _i12;
import 'package:mamacare_client/src/protocol/kick_session.dart' as _i13;
import 'package:mamacare_client/src/protocol/medication.dart' as _i14;
import 'package:mamacare_client/src/protocol/ultrasound_scan.dart' as _i15;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i16;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i17;
export 'auth_exception.dart';
export 'auth_response.dart';
export 'greetings/greeting.dart';
export 'health_checkin.dart';
export 'kick_session.dart';
export 'maternal_profile.dart';
export 'medication.dart';
export 'ultrasound_analysis_result.dart';
export 'ultrasound_scan.dart';
export 'user.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AuthException) {
      return _i2.AuthException.fromJson(data) as T;
    }
    if (t == _i3.AuthResponse) {
      return _i3.AuthResponse.fromJson(data) as T;
    }
    if (t == _i4.Greeting) {
      return _i4.Greeting.fromJson(data) as T;
    }
    if (t == _i5.HealthCheckin) {
      return _i5.HealthCheckin.fromJson(data) as T;
    }
    if (t == _i6.KickSession) {
      return _i6.KickSession.fromJson(data) as T;
    }
    if (t == _i7.MaternalProfile) {
      return _i7.MaternalProfile.fromJson(data) as T;
    }
    if (t == _i8.Medication) {
      return _i8.Medication.fromJson(data) as T;
    }
    if (t == _i9.UltrasoundAnalysisResult) {
      return _i9.UltrasoundAnalysisResult.fromJson(data) as T;
    }
    if (t == _i10.UltrasoundScan) {
      return _i10.UltrasoundScan.fromJson(data) as T;
    }
    if (t == _i11.User) {
      return _i11.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AuthException?>()) {
      return (data != null ? _i2.AuthException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AuthResponse?>()) {
      return (data != null ? _i3.AuthResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Greeting?>()) {
      return (data != null ? _i4.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.HealthCheckin?>()) {
      return (data != null ? _i5.HealthCheckin.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.KickSession?>()) {
      return (data != null ? _i6.KickSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.MaternalProfile?>()) {
      return (data != null ? _i7.MaternalProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Medication?>()) {
      return (data != null ? _i8.Medication.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.UltrasoundAnalysisResult?>()) {
      return (data != null ? _i9.UltrasoundAnalysisResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.UltrasoundScan?>()) {
      return (data != null ? _i10.UltrasoundScan.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.User?>()) {
      return (data != null ? _i11.User.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_i12.HealthCheckin>) {
      return (data as List)
              .map((e) => deserialize<_i12.HealthCheckin>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.KickSession>) {
      return (data as List)
              .map((e) => deserialize<_i13.KickSession>(e))
              .toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i14.Medication>) {
      return (data as List).map((e) => deserialize<_i14.Medication>(e)).toList()
          as T;
    }
    if (t == List<_i15.UltrasoundScan>) {
      return (data as List)
              .map((e) => deserialize<_i15.UltrasoundScan>(e))
              .toList()
          as T;
    }
    try {
      return _i16.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i17.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AuthException => 'AuthException',
      _i3.AuthResponse => 'AuthResponse',
      _i4.Greeting => 'Greeting',
      _i5.HealthCheckin => 'HealthCheckin',
      _i6.KickSession => 'KickSession',
      _i7.MaternalProfile => 'MaternalProfile',
      _i8.Medication => 'Medication',
      _i9.UltrasoundAnalysisResult => 'UltrasoundAnalysisResult',
      _i10.UltrasoundScan => 'UltrasoundScan',
      _i11.User => 'User',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('mamacare.', '');
    }

    switch (data) {
      case _i2.AuthException():
        return 'AuthException';
      case _i3.AuthResponse():
        return 'AuthResponse';
      case _i4.Greeting():
        return 'Greeting';
      case _i5.HealthCheckin():
        return 'HealthCheckin';
      case _i6.KickSession():
        return 'KickSession';
      case _i7.MaternalProfile():
        return 'MaternalProfile';
      case _i8.Medication():
        return 'Medication';
      case _i9.UltrasoundAnalysisResult():
        return 'UltrasoundAnalysisResult';
      case _i10.UltrasoundScan():
        return 'UltrasoundScan';
      case _i11.User():
        return 'User';
    }
    className = _i16.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i17.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AuthException') {
      return deserialize<_i2.AuthException>(data['data']);
    }
    if (dataClassName == 'AuthResponse') {
      return deserialize<_i3.AuthResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i4.Greeting>(data['data']);
    }
    if (dataClassName == 'HealthCheckin') {
      return deserialize<_i5.HealthCheckin>(data['data']);
    }
    if (dataClassName == 'KickSession') {
      return deserialize<_i6.KickSession>(data['data']);
    }
    if (dataClassName == 'MaternalProfile') {
      return deserialize<_i7.MaternalProfile>(data['data']);
    }
    if (dataClassName == 'Medication') {
      return deserialize<_i8.Medication>(data['data']);
    }
    if (dataClassName == 'UltrasoundAnalysisResult') {
      return deserialize<_i9.UltrasoundAnalysisResult>(data['data']);
    }
    if (dataClassName == 'UltrasoundScan') {
      return deserialize<_i10.UltrasoundScan>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i11.User>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i16.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i17.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
