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

abstract class HealthCheckin implements _i1.SerializableModel {
  HealthCheckin._({
    this.id,
    required this.userId,
    required this.checkInDate,
    required this.pregnancyWeek,
    required this.hasSevereHeadache,
    required this.hasVisionChanges,
    required this.hasAbdominalPain,
    required this.hasSwelling,
    required this.hasReducedFetalMovement,
    required this.hasVaginalBleeding,
    required this.hasFluidLeakage,
    required this.hasContractions,
    this.systolicBP,
    this.diastolicBP,
    this.weight,
    this.additionalSymptoms,
    String? aiRiskAssessment,
    String? riskLevel,
    String? recommendations,
    DateTime? createdAt,
  }) : aiRiskAssessment = aiRiskAssessment ?? 'Pending analysis',
       riskLevel = riskLevel ?? 'MEDIUM',
       recommendations =
           recommendations ?? 'Please consult your healthcare provider',
       createdAt = createdAt ?? DateTime.now();

  factory HealthCheckin({
    int? id,
    required int userId,
    required DateTime checkInDate,
    required int pregnancyWeek,
    required bool hasSevereHeadache,
    required bool hasVisionChanges,
    required bool hasAbdominalPain,
    required bool hasSwelling,
    required bool hasReducedFetalMovement,
    required bool hasVaginalBleeding,
    required bool hasFluidLeakage,
    required bool hasContractions,
    int? systolicBP,
    int? diastolicBP,
    double? weight,
    String? additionalSymptoms,
    String? aiRiskAssessment,
    String? riskLevel,
    String? recommendations,
    DateTime? createdAt,
  }) = _HealthCheckinImpl;

  factory HealthCheckin.fromJson(Map<String, dynamic> jsonSerialization) {
    return HealthCheckin(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      checkInDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['checkInDate'],
      ),
      pregnancyWeek: jsonSerialization['pregnancyWeek'] as int,
      hasSevereHeadache: jsonSerialization['hasSevereHeadache'] as bool,
      hasVisionChanges: jsonSerialization['hasVisionChanges'] as bool,
      hasAbdominalPain: jsonSerialization['hasAbdominalPain'] as bool,
      hasSwelling: jsonSerialization['hasSwelling'] as bool,
      hasReducedFetalMovement:
          jsonSerialization['hasReducedFetalMovement'] as bool,
      hasVaginalBleeding: jsonSerialization['hasVaginalBleeding'] as bool,
      hasFluidLeakage: jsonSerialization['hasFluidLeakage'] as bool,
      hasContractions: jsonSerialization['hasContractions'] as bool,
      systolicBP: jsonSerialization['systolicBP'] as int?,
      diastolicBP: jsonSerialization['diastolicBP'] as int?,
      weight: (jsonSerialization['weight'] as num?)?.toDouble(),
      additionalSymptoms: jsonSerialization['additionalSymptoms'] as String?,
      aiRiskAssessment: jsonSerialization['aiRiskAssessment'] as String,
      riskLevel: jsonSerialization['riskLevel'] as String,
      recommendations: jsonSerialization['recommendations'] as String,
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

  DateTime checkInDate;

  int pregnancyWeek;

  bool hasSevereHeadache;

  bool hasVisionChanges;

  bool hasAbdominalPain;

  bool hasSwelling;

  bool hasReducedFetalMovement;

  bool hasVaginalBleeding;

  bool hasFluidLeakage;

  bool hasContractions;

  int? systolicBP;

  int? diastolicBP;

  double? weight;

  String? additionalSymptoms;

  String aiRiskAssessment;

  String riskLevel;

  String recommendations;

  DateTime createdAt;

  /// Returns a shallow copy of this [HealthCheckin]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HealthCheckin copyWith({
    int? id,
    int? userId,
    DateTime? checkInDate,
    int? pregnancyWeek,
    bool? hasSevereHeadache,
    bool? hasVisionChanges,
    bool? hasAbdominalPain,
    bool? hasSwelling,
    bool? hasReducedFetalMovement,
    bool? hasVaginalBleeding,
    bool? hasFluidLeakage,
    bool? hasContractions,
    int? systolicBP,
    int? diastolicBP,
    double? weight,
    String? additionalSymptoms,
    String? aiRiskAssessment,
    String? riskLevel,
    String? recommendations,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HealthCheckin',
      if (id != null) 'id': id,
      'userId': userId,
      'checkInDate': checkInDate.toJson(),
      'pregnancyWeek': pregnancyWeek,
      'hasSevereHeadache': hasSevereHeadache,
      'hasVisionChanges': hasVisionChanges,
      'hasAbdominalPain': hasAbdominalPain,
      'hasSwelling': hasSwelling,
      'hasReducedFetalMovement': hasReducedFetalMovement,
      'hasVaginalBleeding': hasVaginalBleeding,
      'hasFluidLeakage': hasFluidLeakage,
      'hasContractions': hasContractions,
      if (systolicBP != null) 'systolicBP': systolicBP,
      if (diastolicBP != null) 'diastolicBP': diastolicBP,
      if (weight != null) 'weight': weight,
      if (additionalSymptoms != null) 'additionalSymptoms': additionalSymptoms,
      'aiRiskAssessment': aiRiskAssessment,
      'riskLevel': riskLevel,
      'recommendations': recommendations,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HealthCheckinImpl extends HealthCheckin {
  _HealthCheckinImpl({
    int? id,
    required int userId,
    required DateTime checkInDate,
    required int pregnancyWeek,
    required bool hasSevereHeadache,
    required bool hasVisionChanges,
    required bool hasAbdominalPain,
    required bool hasSwelling,
    required bool hasReducedFetalMovement,
    required bool hasVaginalBleeding,
    required bool hasFluidLeakage,
    required bool hasContractions,
    int? systolicBP,
    int? diastolicBP,
    double? weight,
    String? additionalSymptoms,
    String? aiRiskAssessment,
    String? riskLevel,
    String? recommendations,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         checkInDate: checkInDate,
         pregnancyWeek: pregnancyWeek,
         hasSevereHeadache: hasSevereHeadache,
         hasVisionChanges: hasVisionChanges,
         hasAbdominalPain: hasAbdominalPain,
         hasSwelling: hasSwelling,
         hasReducedFetalMovement: hasReducedFetalMovement,
         hasVaginalBleeding: hasVaginalBleeding,
         hasFluidLeakage: hasFluidLeakage,
         hasContractions: hasContractions,
         systolicBP: systolicBP,
         diastolicBP: diastolicBP,
         weight: weight,
         additionalSymptoms: additionalSymptoms,
         aiRiskAssessment: aiRiskAssessment,
         riskLevel: riskLevel,
         recommendations: recommendations,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [HealthCheckin]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HealthCheckin copyWith({
    Object? id = _Undefined,
    int? userId,
    DateTime? checkInDate,
    int? pregnancyWeek,
    bool? hasSevereHeadache,
    bool? hasVisionChanges,
    bool? hasAbdominalPain,
    bool? hasSwelling,
    bool? hasReducedFetalMovement,
    bool? hasVaginalBleeding,
    bool? hasFluidLeakage,
    bool? hasContractions,
    Object? systolicBP = _Undefined,
    Object? diastolicBP = _Undefined,
    Object? weight = _Undefined,
    Object? additionalSymptoms = _Undefined,
    String? aiRiskAssessment,
    String? riskLevel,
    String? recommendations,
    DateTime? createdAt,
  }) {
    return HealthCheckin(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      checkInDate: checkInDate ?? this.checkInDate,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      hasSevereHeadache: hasSevereHeadache ?? this.hasSevereHeadache,
      hasVisionChanges: hasVisionChanges ?? this.hasVisionChanges,
      hasAbdominalPain: hasAbdominalPain ?? this.hasAbdominalPain,
      hasSwelling: hasSwelling ?? this.hasSwelling,
      hasReducedFetalMovement:
          hasReducedFetalMovement ?? this.hasReducedFetalMovement,
      hasVaginalBleeding: hasVaginalBleeding ?? this.hasVaginalBleeding,
      hasFluidLeakage: hasFluidLeakage ?? this.hasFluidLeakage,
      hasContractions: hasContractions ?? this.hasContractions,
      systolicBP: systolicBP is int? ? systolicBP : this.systolicBP,
      diastolicBP: diastolicBP is int? ? diastolicBP : this.diastolicBP,
      weight: weight is double? ? weight : this.weight,
      additionalSymptoms: additionalSymptoms is String?
          ? additionalSymptoms
          : this.additionalSymptoms,
      aiRiskAssessment: aiRiskAssessment ?? this.aiRiskAssessment,
      riskLevel: riskLevel ?? this.riskLevel,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
