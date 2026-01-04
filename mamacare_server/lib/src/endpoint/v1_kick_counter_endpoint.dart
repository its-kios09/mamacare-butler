import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';

class V1KickCounterEndpoint extends Endpoint {
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

  Future<List<KickSession>> getUserSessions(
    Session session,
    int userId,
  ) async {
    try {
      final sessions = await KickSession.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        orderBy: (t) => t.sessionDate,
        orderDescending: true,
        limit: 100,
      );

      session.log(
        'Retrieved ${sessions.length} kick sessions for user $userId',
      );

      return sessions;
    } catch (e) {
      session.log('Error getting user sessions: $e', level: LogLevel.error);
      return [];
    }
  }
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
      session.log('Error calculating kick stats: $e', level: LogLevel.error);
      return {'error': e.toString()};
    }
  }

  Future<String> getAIInsight(
    Session session,
    int userId,
    int pregnancyWeek,
  ) async {
    try {
      final sessions = await getRecentKicks(session, userId, 7);

      if (sessions.isEmpty) {
        return 'Start counting kicks to get AI insights!';
      }

      final sessionData = sessions
          .map(
            (s) => {
              'kickCount': s.kickCount,
              'durationMinutes': s.durationMinutes,
            },
          )
          .toList();

      final gemini = GeminiService();
      final insight = await gemini.analyzeKickPattern(
        sessions: sessionData,
        pregnancyWeek: pregnancyWeek,
      );

      session.log('AI insight generated for user $userId');
      return insight;
    } catch (e) {
      session.log('Error getting AI insight: $e', level: LogLevel.error);
      return 'AI analysis temporarily unavailable.';
    }
  }
}
