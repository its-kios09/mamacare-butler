import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';
import 'dart:convert';

class V1UltrasoundEndpoint extends Endpoint {
  /// Analyze ultrasound image with Gemini Vision
  Future<Map<String, dynamic>> analyzeUltrasound(
    Session session,
    int userId,
    String imageBase64,
    int pregnancyWeek,
  ) async {
    try {
      session.log(
        '🔍 Analyzing ultrasound for user $userId, week $pregnancyWeek',
      );

      final gemini = GeminiService();
      final result = await gemini.analyzeUltrasound(
        imageBase64: imageBase64,
        pregnancyWeek: pregnancyWeek,
      );

      session.log('✅ Ultrasound analyzed successfully');
      return result;
    } catch (e, stackTrace) {
      session.log('❌ Error analyzing ultrasound: $e', level: LogLevel.error);
      session.log('Stack: $stackTrace', level: LogLevel.error);
      return {
        'measurements': {},
        'explanation': 'Unable to analyze ultrasound. Please try again.',
        'nextScanRecommended': null,
      };
    }
  }

  /// Save ultrasound scan record
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
      session.log('✅ Ultrasound scan saved: ${saved.id}');

      return saved;
    } catch (e) {
      session.log('❌ Error saving scan: $e', level: LogLevel.error);
      return null;
    }
  }

  /// Get user's ultrasound history
  Future<List<UltrasoundScan>> getUserScans(
    Session session,
    int userId,
  ) async {
    try {
      final scans = await UltrasoundScan.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        orderBy: (t) => t.scanDate,
        orderDescending: true,
      );

      session.log('✅ Retrieved ${scans.length} ultrasound scans');
      return scans;
    } catch (e) {
      session.log('❌ Error getting scans: $e', level: LogLevel.error);
      return [];
    }
  }
}
