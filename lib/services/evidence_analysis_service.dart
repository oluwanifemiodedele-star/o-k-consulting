import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../models/evidence.dart';
import 'app_settings.dart';

class EvidenceAnalysisService {
  EvidenceAnalysisService._();

  static Future<EvidenceAnalysis> analyze({
    required Business business,
    required Evidence evidence,
  }) async {
    final url = AppSettings.instance.webhookUrl;
    if (url == null) {
      throw StateError('No n8n webhook URL configured. Add one in Settings first.');
    }

    final payload = {
      'businessName': business.name,
      'businessType': business.businessType,
      'sector': business.sector,
      'location': business.location,
      'yearsOperating': business.yearsOperating,
      'collectedInfo': business.standardizedInfo ?? business.collectedInfo,
      'evidenceDescription': evidence.description,
      if (evidence.imageBytes != null) 'evidenceImageBase64': base64Encode(evidence.imageBytes!),
      if (evidence.imageName != null) 'evidenceImageName': evidence.imageName,
    };

    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw StateError('Could not reach the webhook: $e');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Webhook returned ${response.statusCode}: ${response.body}');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Webhook response was not valid JSON.');
    }

    if (!data.containsKey('agrees') || !data.containsKey('confidence') || !data.containsKey('reasoning')) {
      throw const FormatException(
        'Webhook response is missing expected fields (agrees, confidence, reasoning).',
      );
    }

    return EvidenceAnalysis(
      agrees: data['agrees'] as bool,
      confidencePercent: (data['confidence'] as num).round(),
      reasoning: data['reasoning'] as String,
    );
  }
}