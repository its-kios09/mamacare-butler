import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dotenv/dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final env = DotEnv()..load();
    final apiKey = env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
    );
  }

  String _getExpectedActivity(int week) {
    if (week < 20) return 'Light flutters, may not be felt consistently';
    if (week < 28) return 'Regular movements, 10+ kicks per 2 hours';
    if (week < 36) return 'Strong, frequent movements throughout day';
    return 'Consistent movements, may feel different as space decreases';
  }

  String _getTrimester(int week) {
    if (week <= 12) return 'First';
    if (week <= 26) return 'Second';
    return 'Third';
  }

  Future<String> analyzeKickPattern({
    required List<Map<String, dynamic>> sessions,
    required int pregnancyWeek,
  }) async {
    if (sessions.isEmpty) {
      return '🤰 Start counting kicks to receive personalized AI insights!\n\n'
          '💡 Tip: Count 10 movements twice daily. Normal is 10-30 kicks in 2 hours.';
    }

    if (sessions.length < 2) {
      final count = sessions[0]['kickCount'] as int;
      final duration = sessions[0]['durationMinutes'] as int;

      if (count >= 10) {
        return '✅ Great start! You counted $count kicks in $duration minutes.\n\n'
            '📊 Keep tracking for 2-3 more sessions so I can detect meaningful patterns and trends.';
      } else {
        return '📝 First session recorded: $count kicks in $duration minutes.\n\n'
            '💡 If you don\'t reach 10 kicks within 2 hours, try counting at a different time when baby is usually active.';
      }
    }

    // Calculate statistics
    final kickCounts = sessions.map((s) => s['kickCount'] as int).toList();
    final durations = sessions.map((s) => s['durationMinutes'] as int).toList();

    final avgKicks = (kickCounts.reduce((a, b) => a + b) / kickCounts.length)
        .round();
    final maxKicks = kickCounts.reduce((a, b) => a > b ? a : b);
    final minKicks = kickCounts.reduce((a, b) => a < b ? a : b);
    final avgDuration = (durations.reduce((a, b) => a + b) / durations.length)
        .round();

    // Detect trends (last 3 sessions)
    String trend = 'stable';
    if (kickCounts.length >= 3) {
      final recent = kickCounts.sublist(0, 3);
      if (recent[0] < recent[1] && recent[1] < recent[2]) {
        trend = 'increasing';
      } else if (recent[0] > recent[1] && recent[1] > recent[2]) {
        trend = 'decreasing';
      }
    }

    // Format session data
   // Format session data
    final sessionDetails = sessions
        .take(5)
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final s = entry.value;
          final daysAgo = index;
          final timeLabel = daysAgo == 0
              ? "Today"
              : daysAgo == 1
              ? "Yesterday"
              : "$daysAgo days ago";
          return '$timeLabel: ${s['kickCount']} kicks in ${s['durationMinutes']} mins';
        })
        .join('\n');

    final prompt =
        '''
You are Dr. MamaCare AI, a maternal health expert powered by Gemini 3. Analyze this kick count pattern with clinical precision and empathy.

PREGNANCY CONTEXT:
- Week: $pregnancyWeek of 40
- Trimester: ${_getTrimester(pregnancyWeek)}
- Expected activity: ${_getExpectedActivity(pregnancyWeek)}

KICK COUNT DATA (Last ${sessions.length} sessions):
$sessionDetails

STATISTICAL ANALYSIS:
- Average: $avgKicks kicks per session
- Range: $minKicks - $maxKicks kicks
- Average duration: $avgDuration minutes
- Trend: $trend

CLINICAL GUIDELINES:
- Normal for week $pregnancyWeek: 10-30 kicks in 2 hours
- Concerning: <10 kicks in 2 hours OR sudden 50% decrease
- Emergency: No movement in 2+ hours after stimulation

Provide a personalized assessment in this EXACT format:

[STATUS EMOJI] [ONE-WORD STATUS]

[2-3 SENTENCES: Pattern analysis comparing to normal range for this week, mention the trend, and explain what it means clinically]

[1 SENTENCE: Specific actionable recommendation]

Use these status indicators:
✅ EXCELLENT - Well above normal, very active
👍 GOOD - Within healthy range, consistent  
⚠️ ATTENTION - Below expected or concerning pattern
🚨 URGENT - Immediate medical attention needed

Be warm, reassuring, and clear. Use mother-friendly language. Maximum 80 words total.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final insight =
          response.text ?? 'Unable to generate insight at this time.';

      // Clean up the response
      return insight.trim();
    } catch (e) {
      print('Gemini error: $e');

      // Provide intelligent fallback based on data
      if (avgKicks >= 15 && minKicks >= 10) {
        return '✅ EXCELLENT\n\n'
            'Your baby is very active with an average of $avgKicks kicks per session. '
            'All sessions show healthy movement patterns for week $pregnancyWeek. '
            'Continue monitoring twice daily!';
      } else if (avgKicks >= 10) {
        return '👍 GOOD\n\n'
            'Your kick counts are healthy and within normal range for week $pregnancyWeek. '
            'Average of $avgKicks kicks shows consistent fetal activity. '
            'Keep up the great tracking!';
      } else if (minKicks < 10) {
        return '⚠️ ATTENTION\n\n'
            'Some sessions show fewer than 10 kicks. This may be normal, but try counting '
            'when baby is usually active (after meals or at night). '
            'Contact your healthcare provider if this pattern continues.';
      } else {
        return 'AI analysis temporarily unavailable. Your average is $avgKicks kicks. '
            'Normal range is 10-30 kicks in 2 hours. Contact your doctor if concerned.';
      }
    }
  }
}
