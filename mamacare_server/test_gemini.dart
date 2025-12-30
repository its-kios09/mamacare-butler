
import 'package:mamacare_server/src/services/gemini_service.dart';

void main() async {
  print('🧪 Testing Gemini for Hackathon...\n');

  try {
    final gemini = GeminiService();
    print('✅ Service created\n');

    final testSessions = [
      {'kickCount': 22, 'durationMinutes': 15},
      {'kickCount': 20, 'durationMinutes': 12},
      {'kickCount': 24, 'durationMinutes': 18},
      {'kickCount': 19, 'durationMinutes': 14},
      {'kickCount': 23, 'durationMinutes': 16},
    ];

    print('📊 Test data: 5 sessions, avg 21.6 kicks\n');
    print('🤖 Calling Gemini 3...\n');

    final insight = await gemini.analyzeKickPattern(
      sessions: testSessions,
      pregnancyWeek: 28,
    );

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✨ GEMINI RESPONSE:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(insight);
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    print('🎉 SUCCESS! Gemini 3 is working!');
  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('\n📋 Stack trace:');
    print(stackTrace);
  }
}
