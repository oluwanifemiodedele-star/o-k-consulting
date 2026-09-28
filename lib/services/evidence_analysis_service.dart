import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../models/evidence.dart';
import 'app_settings.dart';

/// Sends a business and its evidence to the configured n8n webhook and
/// turns the response into an EvidenceAnalysis.
class EvidenceAnalysisService {
  /// Private constructor — this class is only ever used through its
  /// static [analyze] method, so it's never meant to be instantiated.
  EvidenceAnalysisService._();

  /// Sends [business] and [evidence] to the configured webhook and
  /// returns the resulting [EvidenceAnalysis].
  ///
  /// Throws a [StateError] if no webhook URL is set, the request can't
  /// reach the server, or the server returns a non-2xx status. Throws a
  /// [FormatException] if the response isn't valid JSON or is missing
  /// expected fields.
  static Future<EvidenceAnalysis> analyze({
    required Business business,
    required Evidence evidence,
  }) async {
    final url = AppSettings.instance.webhookUrl;
    if (url == null) {
      throw StateError('No n8n webhook URL configured. Add one in Settings first.');
    }

    // Use the cleaned data if it exists, otherwise fall back to raw.
    final payload = {
      'businessName': business.name,
      'businessType': business.businessType,
      'sector': business.sector,
      'location': business.location,
      'yearsOperating': business.yearsOperating,
      'collectedInfo': business.standardizedInfo ?? business.collectedInfo,
      'evidenceDescription': evidence.description,
      // Only send image fields if there's actually an image.
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
          // Longer timeout since the webhook will be calling an AI model itself.
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

    // Check the shape before reading fields, so a bad response gives a
    // clear error instead of a confusing type-cast crash below.
    if (!data.containsKey('agrees') || !data.containsKey('confidence') || !data.containsKey('reasoning')) {
      throw const FormatException(
        'Webhook response is missing expected fields (agrees, confidence, reasoning).',
      );
    }

    return EvidenceAnalysis(
      agrees: data['agrees'] as bool,
      // Confidence can come back as a decimal (e.g. 87.5), round to a whole percent.
      confidencePercent: (data['confidence'] as num).round(),
      reasoning: data['reasoning'] as String,
    );
  }
}