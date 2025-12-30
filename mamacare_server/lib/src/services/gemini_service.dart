import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dotenv/dotenv.dart';
import 'dart:convert';

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

  /// Ultrasound analysis - Vision model
  Future<Map<String, dynamic>> analyzeUltrasound({
    required String imageBase64,
    required int pregnancyWeek,
  }) async {
    final prompt =
        '''
You are Dr. MamaCare AI, a maternal health expert analyzing an ultrasound scan.

PREGNANCY CONTEXT:
- Week: $pregnancyWeek of 40
- Trimester: ${_getTrimester(pregnancyWeek)}

TASK:
Carefully examine this ultrasound image and extract ALL visible measurements.

LOOK FOR these common measurements (mark as "Not visible" if you cannot see them):
- GA (Gestational Age)
- BPD (Biparietal Diameter) - head width
- HC (Head Circumference)
- AC (Abdominal Circumference)
- FL (Femur Length) - thigh bone
- EFW (Estimated Fetal Weight)
- AFI (Amniotic Fluid Index)
- Placenta location

PROVIDE response as JSON:
{
  "measurements": {
    "BPD": "7.2 cm" or "Not visible",
    "FL": "5.4 cm" or "Not visible",
    "AC": "24.3 cm" or "Not visible",
    "EFW": "1.2 kg" or "Not visible"
  },
  "explanation": "Your detailed explanation here...",
  "nextScanRecommended": {
    "week": 32,
    "date": "2026-01-28",
    "reason": "Growth and position check"
  }
}

EXPLANATION REQUIREMENTS:
1. Start with overall assessment (Excellent/Good/Normal/Attention needed)
2. Explain each measurement in mother-friendly language
3. Compare to expected values for week $pregnancyWeek
4. Be warm, reassuring, and clear
5. Mention if follow-up needed
6. Maximum 200 words

If the image is unclear or not an ultrasound, say so honestly.
''';

    try {
      // Decode base64 to bytes
      final bytes = base64Decode(imageBase64);

      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ]),
      ]);

      final text = response.text ?? '';

      // Try to parse JSON from response
      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final parsed = json.decode(jsonStr) as Map<String, dynamic>;

          return parsed;
        }
      } catch (e) {
        print('JSON parse error: $e');
      }

      // Fallback if JSON parsing fails
      return {
        'measurements': {},
        'explanation': text.isNotEmpty
            ? text
            : 'Unable to analyze ultrasound image. Please ensure the image is clear.',
        'nextScanRecommended': null,
      };
    } catch (e) {
      print('Gemini Vision error: $e');
      return {
        'measurements': {},
        'explanation':
            'Unable to analyze ultrasound at this time. Error: ${e.toString()}',
        'nextScanRecommended': null,
      };
    }
  }
}
