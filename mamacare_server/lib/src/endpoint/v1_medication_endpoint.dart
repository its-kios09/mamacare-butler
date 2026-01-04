import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class V1MedicationEndpoint extends Endpoint {
  Future<Medication?> addMedication(
    Session session,
    int userId,
    String medicationName,
    String dosage,
    String frequency,
    List<String> reminderTimes,
    DateTime startDate,
    DateTime? endDate,
    String? notes,
  ) async {
    try {
      session.log('Adding medication for user $userId: $medicationName');

      final medication = Medication(
        userId: userId,
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        reminderTimes: reminderTimes,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final saved = await Medication.db.insertRow(session, medication);

      session.log('Medication added: ${saved.id} - ${saved.medicationName}');

      return saved;
    } catch (e) {
      session.log('Error adding medication: $e', level: LogLevel.error);
      return null;
    }
  }

  Future<List<Medication>> getUserMedications(
    Session session,
    int userId,
  ) async {
    try {
      final medications = await Medication.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        orderBy: (t) => t.createdAt,
        orderDescending: true,
      );

      session.log(
        'Retrieved ${medications.length} medications for user $userId',
      );

      return medications;
    } catch (e) {
      session.log('Error getting medications: $e', level: LogLevel.error);
      return [];
    }
  }

  Future<List<Medication>> getActiveMedications(
    Session session,
    int userId,
  ) async {
    try {
      final medications = await Medication.db.find(
        session,
        where: (t) => (t.userId.equals(userId)) & (t.isActive.equals(true)),
        orderBy: (t) => t.createdAt,
        orderDescending: true,
      );

      session.log('Retrieved ${medications.length} active medications');

      return medications;
    } catch (e) {
      session.log(
        'Error getting active medications: $e',
        level: LogLevel.error,
      );
      return [];
    }
  }

  Future<Medication?> updateMedication(
    Session session,
    int medicationId,
    String medicationName,
    String dosage,
    String frequency,
    List<String> reminderTimes,
    DateTime startDate,
    DateTime? endDate,
    String? notes,
    bool isActive,
  ) async {
    try {
      final existing = await Medication.db.findById(session, medicationId);
      if (existing == null) {
        session.log(' Medication not found: $medicationId');
        return null;
      }

      final updated = existing.copyWith(
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        reminderTimes: reminderTimes,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
        isActive: isActive,
      );

      await Medication.db.updateRow(session, updated);

      session.log('✅ Medication updated: $medicationId');

      return updated;
    } catch (e) {
      session.log('❌ Error updating medication: $e', level: LogLevel.error);
      return null;
    }
  }

  /// Delete medication
  Future<bool> deleteMedication(
    Session session,
    int medicationId,
  ) async {
    try {
      final existing = await Medication.db.findById(session, medicationId);
      if (existing == null) {
        session.log('❌ Medication not found: $medicationId');
        return false;
      }

      await Medication.db.deleteRow(session, existing);

      session.log('✅ Medication deleted: $medicationId');

      return true;
    } catch (e) {
      session.log('❌ Error deleting medication: $e', level: LogLevel.error);
      return false;
    }
  }

  /// Toggle medication active status
  Future<bool> toggleMedicationStatus(
    Session session,
    int medicationId,
  ) async {
    try {
      final medication = await Medication.db.findById(session, medicationId);
      if (medication == null) {
        session.log('❌ Medication not found: $medicationId');
        return false;
      }

      final updated = medication.copyWith(isActive: !medication.isActive);
      await Medication.db.updateRow(session, updated);

      session.log(
        '✅ Medication status toggled: $medicationId -> ${updated.isActive}',
      );

      return true;
    } catch (e) {
      session.log('❌ Error toggling medication: $e', level: LogLevel.error);
      return false;
    }
  }
  
}
