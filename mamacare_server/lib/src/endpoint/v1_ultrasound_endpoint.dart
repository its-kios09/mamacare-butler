import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';

class V1UltrasoundEndpoint extends Endpoint {
  Future<UltrasoundAnalysisResult> analyzeUltrasound(
    Session session,
    int userId,
    String imageBase64,
    int pregnancyWeek,
  ) async {
    try {
      session.log(
        ' Analyzing ultrasound for user $userId, week $pregnancyWeek',
      );
      session.log(' Image size: ${imageBase64.length} characters');

      final startTime = DateTime.now();
      final gemini = GeminiService();

      session.log(' Calling Gemini Vision API...');

      final result = await gemini.analyzeUltrasound(
        imageBase64: imageBase64,
        pregnancyWeek: pregnancyWeek,
      );

      final duration = DateTime.now().difference(startTime);
      session.log('Gemini API call took: ${duration.inMilliseconds}ms');
      session.log('Analysis result keys: ${result.keys.join(", ")}');

      final measurements =
          (result['measurements'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {};

      final nextScan = result['nextScanRecommended'] as Map<String, dynamic>?;
      final nextScanWeek = nextScan?['week'] as int?;
      final nextScanDate = nextScan?['date'] != null
          ? DateTime.tryParse(nextScan!['date'].toString())
          : null;
      final nextScanReason = nextScan?['reason']?.toString();

      session.log('Ultrasound analyzed successfully');
      session.log('Extracted ${measurements.length} measurements');
      if (nextScanWeek != null) {
        session.log('Next scan recommended at week $nextScanWeek');
      }

      return UltrasoundAnalysisResult(
        measurements: measurements,
        explanation:
            result['explanation']?.toString() ??
            'Analysis completed successfully.',
        nextScanWeek: nextScanWeek,
        nextScanDate: nextScanDate,
        nextScanReason: nextScanReason,
      );
    } catch (e, stackTrace) {
      session.log('Error analyzing ultrasound: $e', level: LogLevel.error);
      session.log('Stack trace: $stackTrace', level: LogLevel.error);

      return UltrasoundAnalysisResult(
        measurements: {},
        explanation: 'Unable to analyze ultrasound. Please try again later.',
        nextScanWeek: null,
        nextScanDate: null,
        nextScanReason: null,
      );
    }
  }

  Future<UltrasoundScan?> saveUltrasoundScan(
    Session session,
    int userId,
    int pregnancyWeek,
    String imageBase64,
    String measurements,
    String aiExplanation,
    int? nextScanWeek,
    DateTime? nextScanDate,
  ) async {
    try {
      session.log(
        'Saving ultrasound scan for user $userId, week $pregnancyWeek',
      );
      session.log('Image size: ${imageBase64.length} characters');
      session.log('Measurements: $measurements');

      final scan = UltrasoundScan(
        userId: userId,
        scanDate: DateTime.now(),
        pregnancyWeek: pregnancyWeek,
        imageBase64: imageBase64,
        measurements: measurements,
        aiExplanation: aiExplanation,
        nextScanWeek: nextScanWeek,
        nextScanDate: nextScanDate,
        createdAt: DateTime.now(),
      );

      final saved = await UltrasoundScan.db.insertRow(session, scan);

      session.log('Ultrasound scan saved successfully with ID: ${saved.id}');
      if (nextScanWeek != null) {
        session.log('Reminder set for week $nextScanWeek');
      }

      return saved;
    } catch (e, stackTrace) {
      session.log('Error saving scan: $e', level: LogLevel.error);
      session.log(' Stack trace: $stackTrace', level: LogLevel.error);
      return null;
    }
  }

  Future<List<UltrasoundScan>> getUserScans(
    Session session,
    int userId,
  ) async {
    try {
      session.log('Fetching ultrasound scans for user $userId');

      final scans = await UltrasoundScan.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        orderBy: (t) => t.scanDate,
        orderDescending: true,
      );

      session.log(
        'Retrieved ${scans.length} ultrasound scan${scans.length == 1 ? '' : 's'}',
      );

      return scans;
    } catch (e, stackTrace) {
      session.log('Error getting scans: $e', level: LogLevel.error);
      session.log('Stack trace: $stackTrace', level: LogLevel.error);
      return [];
    }
  }

  Future<String> analyzeHistory(
    Session session,
    int userId,
  ) async {
    try {
      session.log(' Analyzing scan history for user $userId');

      final scans = await UltrasoundScan.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        orderBy: (t) => t.scanDate,
        orderDescending: false,
      );

      if (scans.isEmpty) {
        session.log('No scans found for user $userId');
        return 'No ultrasound scans available for analysis yet. Upload your first scan to get started!';
      }

      session.log(
        'Found ${scans.length} scan${scans.length == 1 ? '' : 's'} to analyze',
      );

      final scanSummaries = scans.map((scan) {
        return {
          'week': scan.pregnancyWeek,
          'date': scan.scanDate.toIso8601String(),
          'measurements': scan.measurements,
          'explanation': scan.aiExplanation,
        };
      }).toList();

      final prompt =
          '''
You are MamaCare AI, a warm and knowledgeable maternal health assistant analyzing pregnancy progression.

 TASK: Analyze these ultrasound scans chronologically and provide a comprehensive pregnancy progress report.

SCAN HISTORY (${scans.length} scan${scans.length == 1 ? '' : 's'}):
${scanSummaries.map((s) {
            return '''
Week ${s['week']} (${s['date']?.toString().split('T')[0]}):
Measurements: ${s['measurements']}
Previous Analysis: ${s['explanation']}
''';
          }).join('\n---\n')}

REQUIRED SECTIONS:
1. **Overall Assessment** - How is the pregnancy progressing?
2. **Growth Trends** - What patterns do you see across scans?
3. **Key Observations** - Notable measurements or developments
4. **Recommendations** - Advice for continued care

 FORMATTING GUIDELINES:
- Use a warm, encouraging tone
- Keep it 250-350 words
- Use simple language mothers can understand
- Include relevant emojis to make it friendly
- Be specific about measurements when relevant
- End with reminder to consult healthcare provider

FOCUS: Give mothers confidence while ensuring they know this is informational, not medical diagnosis.
''';

      session.log(' Calling Gemini for history analysis...');
      final startTime = DateTime.now();

      final gemini = GeminiService();
      final analysis = await gemini.analyzeText(prompt);

      final duration = DateTime.now().difference(startTime);
      session.log(' History analysis took: ${duration.inMilliseconds}ms');
      session.log(' Analysis length: ${analysis.length} characters');
      session.log(' History analysis complete');

      return analysis;
    } catch (e, stackTrace) {
      session.log(' Error analyzing history: $e', level: LogLevel.error);
      session.log(' Stack trace: $stackTrace', level: LogLevel.error);

      return '''
 Analysis Temporarily Unavailable

We encountered an issue while analyzing your scan history. This is usually temporary.

Please try again in a few moments. If the problem persists, contact support.

Your scan data is safe and stored securely.
''';
    }
  }
}
