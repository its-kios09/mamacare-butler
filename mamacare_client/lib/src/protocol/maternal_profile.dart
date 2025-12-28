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

abstract class MaternalProfile implements _i1.SerializableModel {
  MaternalProfile._({
    this.id,
    required this.userId,
    required this.fullName,
    required this.expectedDueDate,
    this.lastMenstrualPeriod,
    required this.currentWeek,
    this.bloodType,
    this.allergies,
    this.medicalHistory,
    this.emergencyContact,
    this.emergencyPhone,
    required this.createdAt,
    this.updatedAt,
  });

  factory MaternalProfile({
    int? id,
    required int userId,
    required String fullName,
    required DateTime expectedDueDate,
    DateTime? lastMenstrualPeriod,
    required int currentWeek,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? emergencyContact,
    String? emergencyPhone,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _MaternalProfileImpl;

  factory MaternalProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MaternalProfile(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      fullName: jsonSerialization['fullName'] as String,
      expectedDueDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expectedDueDate'],
      ),
      lastMenstrualPeriod: jsonSerialization['lastMenstrualPeriod'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastMenstrualPeriod'],
            ),
      currentWeek: jsonSerialization['currentWeek'] as int,
      bloodType: jsonSerialization['bloodType'] as String?,
      allergies: jsonSerialization['allergies'] as String?,
      medicalHistory: jsonSerialization['medicalHistory'] as String?,
      emergencyContact: jsonSerialization['emergencyContact'] as String?,
      emergencyPhone: jsonSerialization['emergencyPhone'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  String fullName;

  DateTime expectedDueDate;

  DateTime? lastMenstrualPeriod;

  int currentWeek;

  String? bloodType;

  String? allergies;

  String? medicalHistory;

  String? emergencyContact;

  String? emergencyPhone;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [MaternalProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MaternalProfile copyWith({
    int? id,
    int? userId,
    String? fullName,
    DateTime? expectedDueDate,
    DateTime? lastMenstrualPeriod,
    int? currentWeek,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MaternalProfile',
      if (id != null) 'id': id,
      'userId': userId,
      'fullName': fullName,
      'expectedDueDate': expectedDueDate.toJson(),
      if (lastMenstrualPeriod != null)
        'lastMenstrualPeriod': lastMenstrualPeriod?.toJson(),
      'currentWeek': currentWeek,
      if (bloodType != null) 'bloodType': bloodType,
      if (allergies != null) 'allergies': allergies,
      if (medicalHistory != null) 'medicalHistory': medicalHistory,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (emergencyPhone != null) 'emergencyPhone': emergencyPhone,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MaternalProfileImpl extends MaternalProfile {
  _MaternalProfileImpl({
    int? id,
    required int userId,
    required String fullName,
    required DateTime expectedDueDate,
    DateTime? lastMenstrualPeriod,
    required int currentWeek,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? emergencyContact,
    String? emergencyPhone,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         fullName: fullName,
         expectedDueDate: expectedDueDate,
         lastMenstrualPeriod: lastMenstrualPeriod,
         currentWeek: currentWeek,
         bloodType: bloodType,
         allergies: allergies,
         medicalHistory: medicalHistory,
         emergencyContact: emergencyContact,
         emergencyPhone: emergencyPhone,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MaternalProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MaternalProfile copyWith({
    Object? id = _Undefined,
    int? userId,
    String? fullName,
    DateTime? expectedDueDate,
    Object? lastMenstrualPeriod = _Undefined,
    int? currentWeek,
    Object? bloodType = _Undefined,
    Object? allergies = _Undefined,
    Object? medicalHistory = _Undefined,
    Object? emergencyContact = _Undefined,
    Object? emergencyPhone = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return MaternalProfile(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      expectedDueDate: expectedDueDate ?? this.expectedDueDate,
      lastMenstrualPeriod: lastMenstrualPeriod is DateTime?
          ? lastMenstrualPeriod
          : this.lastMenstrualPeriod,
      currentWeek: currentWeek ?? this.currentWeek,
      bloodType: bloodType is String? ? bloodType : this.bloodType,
      allergies: allergies is String? ? allergies : this.allergies,
      medicalHistory: medicalHistory is String?
          ? medicalHistory
          : this.medicalHistory,
      emergencyContact: emergencyContact is String?
          ? emergencyContact
          : this.emergencyContact,
      emergencyPhone: emergencyPhone is String?
          ? emergencyPhone
          : this.emergencyPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
