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

abstract class UltrasoundScan implements _i1.SerializableModel {
  UltrasoundScan._({
    this.id,
    required this.userId,
    required this.scanDate,
    required this.pregnancyWeek,
    required this.imageBase64,
    required this.measurements,
    required this.aiExplanation,
    this.nextScanWeek,
    this.nextScanDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UltrasoundScan({
    int? id,
    required int userId,
    required DateTime scanDate,
    required int pregnancyWeek,
    required String imageBase64,
    required String measurements,
    required String aiExplanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
    DateTime? createdAt,
  }) = _UltrasoundScanImpl;

  factory UltrasoundScan.fromJson(Map<String, dynamic> jsonSerialization) {
    return UltrasoundScan(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      scanDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['scanDate'],
      ),
      pregnancyWeek: jsonSerialization['pregnancyWeek'] as int,
      imageBase64: jsonSerialization['imageBase64'] as String,
      measurements: jsonSerialization['measurements'] as String,
      aiExplanation: jsonSerialization['aiExplanation'] as String,
      nextScanWeek: jsonSerialization['nextScanWeek'] as int?,
      nextScanDate: jsonSerialization['nextScanDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextScanDate'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  DateTime scanDate;

  int pregnancyWeek;

  String imageBase64;

  String measurements;

  String aiExplanation;

  int? nextScanWeek;

  DateTime? nextScanDate;

  DateTime createdAt;

  /// Returns a shallow copy of this [UltrasoundScan]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UltrasoundScan copyWith({
    int? id,
    int? userId,
    DateTime? scanDate,
    int? pregnancyWeek,
    String? imageBase64,
    String? measurements,
    String? aiExplanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UltrasoundScan',
      if (id != null) 'id': id,
      'userId': userId,
      'scanDate': scanDate.toJson(),
      'pregnancyWeek': pregnancyWeek,
      'imageBase64': imageBase64,
      'measurements': measurements,
      'aiExplanation': aiExplanation,
      if (nextScanWeek != null) 'nextScanWeek': nextScanWeek,
      if (nextScanDate != null) 'nextScanDate': nextScanDate?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UltrasoundScanImpl extends UltrasoundScan {
  _UltrasoundScanImpl({
    int? id,
    required int userId,
    required DateTime scanDate,
    required int pregnancyWeek,
    required String imageBase64,
    required String measurements,
    required String aiExplanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         scanDate: scanDate,
         pregnancyWeek: pregnancyWeek,
         imageBase64: imageBase64,
         measurements: measurements,
         aiExplanation: aiExplanation,
         nextScanWeek: nextScanWeek,
         nextScanDate: nextScanDate,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UltrasoundScan]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UltrasoundScan copyWith({
    Object? id = _Undefined,
    int? userId,
    DateTime? scanDate,
    int? pregnancyWeek,
    String? imageBase64,
    String? measurements,
    String? aiExplanation,
    Object? nextScanWeek = _Undefined,
    Object? nextScanDate = _Undefined,
    DateTime? createdAt,
  }) {
    return UltrasoundScan(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      scanDate: scanDate ?? this.scanDate,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      imageBase64: imageBase64 ?? this.imageBase64,
      measurements: measurements ?? this.measurements,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      nextScanWeek: nextScanWeek is int? ? nextScanWeek : this.nextScanWeek,
      nextScanDate: nextScanDate is DateTime?
          ? nextScanDate
          : this.nextScanDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
