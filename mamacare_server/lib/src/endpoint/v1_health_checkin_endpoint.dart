import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';

class V1HealthCheckinEndpoint extends Endpoint {
  Future<HealthCheckin?> submitCheckin(
    Session session,
    int userId,
    int pregnancyWeek,
    bool hasSevereHeadache,
    bool hasVisionChanges,
    bool hasAbdominalPain,
    bool hasSwelling,
    bool hasReducedFetalMovement,
    bool hasVaginalBleeding,
    bool hasFluidLeakage,
    bool hasContractions,
    int? systolicBP,
    int? diastolicBP,
    double? weight,
    String? additionalSymptoms,
  ) async {
    try {
      session.log('Processing health check-in for user $userId');

      final aiAnalysis = await _analyzeWithGemini(
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
      );

      final checkin = HealthCheckin(
        userId: userId,
        checkInDate: DateTime.now(),
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
        aiRiskAssessment: aiAnalysis['assessment'],
        riskLevel: aiAnalysis['riskLevel'],
        recommendations: aiAnalysis['recommendations'],
        createdAt: DateTime.now(),
      );

      final saved = await HealthCheckin.db.insertRow(session, checkin);

      session.log(
        'Health check-in saved with ${aiAnalysis['riskLevel']} risk level',
      );

      return saved;
    } catch (e) {
      session.log('Error submitting check-in: $e', level: LogLevel.error);
      return null;
    }
  }

  Future<List<HealthCheckin>> getCheckinHistory(
    Session session,
    int userId, {
    int limit = 10,
  }) async {
    try {
      final checkins = await HealthCheckin.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        orderBy: (t) => t.checkInDate,
        orderDescending: true,
        limit: limit,
      );

      session.log('Found ${checkins.length} check-ins for user $userId');
      return checkins;
    } catch (e) {
      session.log('Error getting check-in history: $e', level: LogLevel.error);
      return [];
    }
  }

  String _getTrimester(int week) {
    if (week <= 12) return 'First';
    if (week <= 26) return 'Second';
    return 'Third';
  }

  Future<Map<String, String>> _analyzeWithGemini({
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
  }) async {
    try {
      final geminiService = GeminiService();

      final symptoms = <String>[];
      if (hasSevereHeadache) symptoms.add('severe headache');
      if (hasVisionChanges)
        symptoms.add('vision changes (blurred vision, seeing spots)');
      if (hasAbdominalPain) symptoms.add('upper abdominal pain');
      if (hasSwelling) symptoms.add('sudden swelling (face, hands, feet)');
      if (hasReducedFetalMovement) symptoms.add('reduced fetal movement');
      if (hasVaginalBleeding) symptoms.add('vaginal bleeding');
      if (hasFluidLeakage) symptoms.add('fluid leakage');
      if (hasContractions) symptoms.add('contractions');

      final bpText = (systolicBP != null && diastolicBP != null)
          ? 'Blood Pressure: $systolicBP/$diastolicBP mmHg'
          : 'Blood Pressure: Not recorded';

      final weightText = weight != null
          ? 'Weight: $weight kg'
          : 'Weight: Not recorded';

      final prompt =
          '''
You are Dr. MamaCare AI, a maternal health expert powered by Gemini 3. Analyze this weekly pregnancy health check-in and provide a risk assessment.

PREGNANCY CONTEXT:
- Week: $pregnancyWeek of 40
- Trimester: ${_getTrimester(pregnancyWeek)}

HEALTH DATA:
Symptoms reported: ${symptoms.isEmpty ? 'None' : symptoms.join(', ')}
$bpText
$weightText
${additionalSymptoms != null && additionalSymptoms.isNotEmpty ? 'Additional notes: $additionalSymptoms' : ''}

CLINICAL FOCUS:
- Pre-eclampsia warning signs: High BP (≥140/90), severe headache, vision changes, upper abdominal pain, sudden swelling
- Preterm labor: Contractions, fluid leakage before week 37
- Fetal wellbeing: Reduced movement (especially after week 28)
- Gestational complications: Bleeding, severe symptoms

You MUST respond in this EXACT format (no other text):

RISK: [LOW/MEDIUM/HIGH]
ASSESSMENT: [2-3 sentences analyzing the symptoms in context of pregnancy week and clinical guidelines]
RECOMMENDATIONS: [Specific actionable advice - when to call doctor, what to monitor, lifestyle tips]

Guidelines:
- LOW: No concerning symptoms, normal values
- MEDIUM: Some symptoms that need monitoring (headaches, mild swelling, borderline BP)
- HIGH: Emergency symptoms (severe bleeding, very high BP ≥160/110, no fetal movement, fluid leakage, severe pain)

Be warm, professional, and mother-friendly. Maximum 150 words total.
''';

      final aiResponse = await geminiService.analyzeText(prompt);

      final riskMatch = RegExp(
        r'RISK:\s*(\w+)',
        caseSensitive: false,
      ).firstMatch(aiResponse);
      final assessmentMatch = RegExp(
        r'ASSESSMENT:\s*(.+?)(?=RECOMMENDATIONS:|$)',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(aiResponse);
      final recommendationsMatch = RegExp(
        r'RECOMMENDATIONS:\s*(.+)$',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(aiResponse);

      final riskLevel = riskMatch?.group(1)?.toUpperCase() ?? 'MEDIUM';
      final assessment =
          assessmentMatch?.group(1)?.trim() ??
          aiResponse
              .replaceAll(RegExp(r'RISK:.*?ASSESSMENT:', dotAll: true), '')
              .trim();
      final recommendations =
          recommendationsMatch?.group(1)?.trim() ??
          'Continue regular prenatal care and monitor your symptoms.';

      return {
        'riskLevel': riskLevel,
        'assessment': assessment.isNotEmpty ? assessment : aiResponse,
        'recommendations': recommendations,
      };
    } catch (e) {
      print('Gemini AI error: $e');

      String riskLevel = 'LOW';
      String assessment =
          'Based on your responses, everything appears normal for week $pregnancyWeek. ';
      String recommendations =
          'Continue regular prenatal checkups and monitor for any changes.';

      if (hasVaginalBleeding || hasFluidLeakage) {
        riskLevel = 'HIGH';
        assessment =
            '⚠️ URGENT: Vaginal bleeding or fluid leakage requires immediate medical attention. ';
        recommendations =
            'Contact your healthcare provider or go to the nearest hospital NOW. Do not wait.';
      } else if ((systolicBP != null && systolicBP >= 160) ||
          (diastolicBP != null && diastolicBP >= 110)) {
        riskLevel = 'HIGH';
        assessment =
            '⚠️ URGENT: Your blood pressure is severely elevated. This could indicate pre-eclampsia. ';
        recommendations =
            'Seek immediate medical attention. Go to the emergency room or call your doctor right away.';
      } else if (hasReducedFetalMovement && pregnancyWeek >= 28) {
        riskLevel = 'HIGH';
        assessment =
            '⚠️ URGENT: Reduced fetal movement after week 28 needs immediate evaluation. ';
        recommendations =
            'Contact your healthcare provider immediately. Try drinking cold water and lying on your left side while counting kicks.';
      }
      else if (hasSevereHeadache || hasVisionChanges || hasAbdominalPain) {
        riskLevel = 'MEDIUM';
        assessment =
            'You have reported symptoms that may indicate pre-eclampsia. These need monitoring. ';
        recommendations =
            'Contact your healthcare provider within 24 hours. Monitor your blood pressure if possible. Rest and stay hydrated.';
      } else if (hasSwelling) {
        riskLevel = 'MEDIUM';
        assessment =
            'Swelling is common in pregnancy but can sometimes indicate pre-eclampsia when combined with other symptoms. ';
        recommendations =
            'Monitor for sudden swelling, especially in face and hands. Elevate your feet, reduce salt intake, and stay hydrated.';
      } else if ((systolicBP != null && systolicBP >= 140) ||
          (diastolicBP != null && diastolicBP >= 90)) {
        riskLevel = 'MEDIUM';
        assessment =
            'Your blood pressure is elevated (high-normal). This requires monitoring for pre-eclampsia. ';
        recommendations =
            'Contact your doctor to report your blood pressure. Monitor daily and watch for headaches, vision changes, or swelling.';
      } else if (hasContractions && pregnancyWeek < 37) {
        riskLevel = 'MEDIUM';
        assessment =
            'Contractions before week 37 could indicate preterm labor. ';
        recommendations =
            'Time your contractions. If they are regular (every 10 minutes or less), contact your healthcare provider.';
      }

      return {
        'riskLevel': riskLevel,
        'assessment': assessment,
        'recommendations': recommendations,
      };
    }
  }
}
