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

abstract class Medication implements _i1.SerializableModel {
  Medication._({
    this.id,
    required this.userId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.notes,
    bool? isActive,
    DateTime? createdAt,
  }) : isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory Medication({
    int? id,
    required int userId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  }) = _MedicationImpl;

  factory Medication.fromJson(Map<String, dynamic> jsonSerialization) {
    return Medication(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      medicationName: jsonSerialization['medicationName'] as String,
      dosage: jsonSerialization['dosage'] as String,
      frequency: jsonSerialization['frequency'] as String,
      reminderTimes: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['reminderTimes'],
      ),
      startDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startDate'],
      ),
      endDate: jsonSerialization['endDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endDate']),
      notes: jsonSerialization['notes'] as String?,
      isActive: jsonSerialization['isActive'] as bool,
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

  String medicationName;

  String dosage;

  String frequency;

  List<String> reminderTimes;

  DateTime startDate;

  DateTime? endDate;

  String? notes;

  bool isActive;

  DateTime createdAt;

  /// Returns a shallow copy of this [Medication]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Medication copyWith({
    int? id,
    int? userId,
    String? medicationName,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Medication',
      if (id != null) 'id': id,
      'userId': userId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'reminderTimes': reminderTimes.toJson(),
      'startDate': startDate.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      if (notes != null) 'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MedicationImpl extends Medication {
  _MedicationImpl({
    int? id,
    required int userId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         medicationName: medicationName,
         dosage: dosage,
         frequency: frequency,
         reminderTimes: reminderTimes,
         startDate: startDate,
         endDate: endDate,
         notes: notes,
         isActive: isActive,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Medication]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Medication copyWith({
    Object? id = _Undefined,
    int? userId,
    String? medicationName,
    String? dosage,
    String? frequency,
    List<String>? reminderTimes,
    DateTime? startDate,
    Object? endDate = _Undefined,
    Object? notes = _Undefined,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Medication(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTimes:
          reminderTimes ?? this.reminderTimes.map((e0) => e0).toList(),
      startDate: startDate ?? this.startDate,
      endDate: endDate is DateTime? ? endDate : this.endDate,
      notes: notes is String? ? notes : this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
