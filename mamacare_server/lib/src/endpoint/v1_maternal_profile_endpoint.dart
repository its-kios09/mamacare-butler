import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class V1MaternalProfileEndpoint extends Endpoint {
  Future<MaternalProfile?> saveProfile(
    Session session,
    int userId,
    String fullName,
    DateTime expectedDueDate,
    DateTime? lastMenstrualPeriod,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? emergencyContact,
    String? emergencyPhone,
  ) async {
    try {
      final now = DateTime.now();
      final lmp =
          lastMenstrualPeriod ??
          expectedDueDate.subtract(const Duration(days: 280));
      final daysSinceLMP = now.difference(lmp).inDays;
      final currentWeek = (daysSinceLMP / 7).floor();

      final existing = await MaternalProfile.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userId),
      );

      if (existing != null) {
        final updated = existing.copyWith(
          fullName: fullName,
          expectedDueDate: expectedDueDate,
          lastMenstrualPeriod: lastMenstrualPeriod,
          currentWeek: currentWeek,
          bloodType: bloodType,
          allergies: allergies,
          medicalHistory: medicalHistory,
          emergencyContact: emergencyContact,
          emergencyPhone: emergencyPhone,
          updatedAt: DateTime.now(),
        );

        await MaternalProfile.db.updateRow(session, updated);
        session.log('Profile updated for user $userId');
        return updated;
      } else {
        final profile = MaternalProfile(
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
          createdAt: DateTime.now(),
        );

        final saved = await MaternalProfile.db.insertRow(session, profile);
        session.log('Profile created for user $userId');
        return saved;
      }
    } catch (e) {
      session.log('Error saving profile: $e', level: LogLevel.error);
      return null;
    }
  }

  Future<MaternalProfile?> getProfile(Session session, int userId) async {
    try {
      final profile = await MaternalProfile.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userId),
      );

      if (profile != null) {
        session.log('Profile found for user $userId');
      } else {
        session.log('No profile found for user $userId');
      }

      return profile;
    } catch (e) {
      session.log('Error getting profile: $e', level: LogLevel.error);
      return null;
    }
  }
  Future<MaternalProfile?> updateProfile(
    Session session,
    MaternalProfile profile,
  ) async {
    try {
      final existing = await MaternalProfile.db.findById(session, profile.id!);

      if (existing == null) {
        session.log('Profile not found: ${profile.id}');
        return null;
      }

      final updated = profile.copyWith(
        updatedAt: DateTime.now(),
      );

      await MaternalProfile.db.updateRow(session, updated);

      session.log('Profile updated for user ${profile.userId}');

      return updated;
    } catch (e) {
      session.log('Error updating profile: $e', level: LogLevel.error);
      return null;
    }
  }
}
