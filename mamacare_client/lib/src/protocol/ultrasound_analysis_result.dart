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
import 'package:mamacare_client/src/protocol/protocol.dart' as _i2;

abstract class UltrasoundAnalysisResult implements _i1.SerializableModel {
  UltrasoundAnalysisResult._({
    required this.measurements,
    required this.explanation,
    this.nextScanWeek,
    this.nextScanDate,
    this.nextScanReason,
  });

  factory UltrasoundAnalysisResult({
    required Map<String, String> measurements,
    required String explanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
    String? nextScanReason,
  }) = _UltrasoundAnalysisResultImpl;

  factory UltrasoundAnalysisResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UltrasoundAnalysisResult(
      measurements: _i2.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['measurements'],
      ),
      explanation: jsonSerialization['explanation'] as String,
      nextScanWeek: jsonSerialization['nextScanWeek'] as int?,
      nextScanDate: jsonSerialization['nextScanDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextScanDate'],
            ),
      nextScanReason: jsonSerialization['nextScanReason'] as String?,
    );
  }

  Map<String, String> measurements;

  String explanation;

  int? nextScanWeek;

  DateTime? nextScanDate;

  String? nextScanReason;

  /// Returns a shallow copy of this [UltrasoundAnalysisResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UltrasoundAnalysisResult copyWith({
    Map<String, String>? measurements,
    String? explanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
    String? nextScanReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UltrasoundAnalysisResult',
      'measurements': measurements.toJson(),
      'explanation': explanation,
      if (nextScanWeek != null) 'nextScanWeek': nextScanWeek,
      if (nextScanDate != null) 'nextScanDate': nextScanDate?.toJson(),
      if (nextScanReason != null) 'nextScanReason': nextScanReason,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UltrasoundAnalysisResultImpl extends UltrasoundAnalysisResult {
  _UltrasoundAnalysisResultImpl({
    required Map<String, String> measurements,
    required String explanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
    String? nextScanReason,
  }) : super._(
         measurements: measurements,
         explanation: explanation,
         nextScanWeek: nextScanWeek,
         nextScanDate: nextScanDate,
         nextScanReason: nextScanReason,
       );

  /// Returns a shallow copy of this [UltrasoundAnalysisResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UltrasoundAnalysisResult copyWith({
    Map<String, String>? measurements,
    String? explanation,
    Object? nextScanWeek = _Undefined,
    Object? nextScanDate = _Undefined,
    Object? nextScanReason = _Undefined,
  }) {
    return UltrasoundAnalysisResult(
      measurements:
          measurements ??
          this.measurements.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      explanation: explanation ?? this.explanation,
      nextScanWeek: nextScanWeek is int? ? nextScanWeek : this.nextScanWeek,
      nextScanDate: nextScanDate is DateTime?
          ? nextScanDate
          : this.nextScanDate,
      nextScanReason: nextScanReason is String?
          ? nextScanReason
          : this.nextScanReason,
    );
  }
}
