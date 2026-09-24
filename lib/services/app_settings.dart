import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._internal();
  static final AppSettings instance = AppSettings._internal();

  /// The n8n webhook URL that receives evidence and returns a real
  /// analysis result.
  String? webhookUrl;

  void setWebhookUrl(String url) {
    final trimmed = url.trim();
    webhookUrl = trimmed.isEmpty ? null : trimmed;
    notifyListeners();
  }
}