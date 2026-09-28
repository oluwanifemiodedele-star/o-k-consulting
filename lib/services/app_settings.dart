import 'package:flutter/foundation.dart';

// App-wide settings, kept as a single shared instance rather than passed
// around everywhere. Notifies listeners so any screen watching this
// rebuilds automatically when a setting changes.
class AppSettings extends ChangeNotifier {
  AppSettings._internal();
  static final AppSettings instance = AppSettings._internal();

  /// The n8n webhook URL that receives evidence and returns a real
  /// analysis result.
  String? webhookUrl;

  // Null out empty/whitespace-only input instead of storing "" — makes
  // "no webhook configured" checks elsewhere just a simple null check.
  void setWebhookUrl(String url) {
    final trimmed = url.trim();
    webhookUrl = trimmed.isEmpty ? null : trimmed;
    notifyListeners();
  }
}