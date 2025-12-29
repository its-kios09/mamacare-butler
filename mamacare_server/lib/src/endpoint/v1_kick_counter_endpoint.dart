import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class V1KickCounterEndpoint extends Endpoint {
  /// Save a kick counting session
  Future<KickSession?> saveKickSession(
    Session session,
    int userId,
    int kickCount,
    int durationMinutes,
    String? notes,
  ) async {
    try {
      final kickSession = KickSession(
        userId: userId,
        sessionDate: DateTime.now(),
        kickCount: kickCount,
        durationMinutes: durationMinutes,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final saved = await KickSession.db.insertRow(session, kickSession);

      session.log('✅ Kick session saved: ${saved.id} - $kickCount kicks');

      return saved;
    } catch (e) {
      session.log('❌ Error saving kick session: $e', level: LogLevel.error);
      return null;
    }
  }

  /// Get recent kick sessions for a user
  Future<List<KickSession>> getRecentKicks(
    Session session,
    int userId,
    int days,
  ) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final sessions = await KickSession.db.find(
        session,
        where: (t) => (t.userId.equals(userId)) & (t.sessionDate >= startDate),
        orderBy: (t) => t.sessionDate,
        orderDescending: true,
      );

      session.log('✅ Retrieved ${sessions.length} kick sessions');

      return sessions;
    } catch (e) {
      session.log('❌ Error getting kick sessions: $e', level: LogLevel.error);
      return [];
    }
  }

  /// Get kick statistics for a user
  Future<Map<String, dynamic>> getKickStats(
    Session session,
    int userId,
    int days,
  ) async {
    try {
      final sessions = await getRecentKicks(session, userId, days);

      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'averageKicks': 0,
          'totalKicks': 0,
          'minKicks': 0,
          'maxKicks': 0,
        };
      }

      final totalKicks = sessions.fold<int>(
        0,
        (sum, s) => sum + s.kickCount,
      );

      final averageKicks = (totalKicks / sessions.length).round();

      final kickCounts = sessions.map((s) => s.kickCount).toList();
      kickCounts.sort();

      final stats = {
        'totalSessions': sessions.length,
        'averageKicks': averageKicks,
        'totalKicks': totalKicks,
        'minKicks': kickCounts.first,
        'maxKicks': kickCounts.last,
      };

      session.log('✅ Kick stats calculated');

      return stats;
    } catch (e) {
      session.log('❌ Error calculating kick stats: $e', level: LogLevel.error);
      return {'error': e.toString()};
    }
  }

  /// Analyze kick pattern (simple version, will add Gemini later)
  Future<String> analyzeKickPattern(
    Session session,
    int userId,
  ) async {
    try {
      final sessions = await getRecentKicks(session, userId, 7);

      if (sessions.isEmpty) {
        return 'Start counting kicks to see AI insights!';
      }

      if (sessions.length < 3) {
        return 'Keep counting! We need at least 3 sessions to analyze patterns.';
      }

      final totalKicks = sessions.fold<int>(0, (sum, s) => sum + s.kickCount);
      final average = (totalKicks / sessions.length).round();

      final recentThree = sessions.take(3).toList();
      final isDecreasing =
          recentThree.length >= 3 &&
          recentThree[0].kickCount < recentThree[1].kickCount &&
          recentThree[1].kickCount < recentThree[2].kickCount;

      final hasLowCount = sessions.any((s) => s.kickCount < 10);

      String insight;
      if (isDecreasing) {
        insight =
            '⚠️ Your kick counts are declining. Consider consulting your doctor.';
      } else if (hasLowCount) {
        insight =
            '⚠️ Some sessions show fewer than 10 kicks. Count for at least 2 hours.';
      } else if (average >= 20) {
        insight =
            '✓ Excellent! Average of $average kicks per session. Very healthy!';
      } else if (average >= 15) {
        insight = '✓ Good! Your kick counts are healthy and consistent.';
      } else {
        insight = 'Your kick counts are within normal range.';
      }

      session.log('✅ Pattern analyzed');
      return insight;
    } catch (e) {
      session.log('❌ Error analyzing pattern: $e', level: LogLevel.error);
      return 'Unable to analyze pattern at this time.';
    }
  }
}
