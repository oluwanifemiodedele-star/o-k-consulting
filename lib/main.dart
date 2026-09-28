import 'package:flutter/material.dart';
import 'screens/shell_screen.dart';
import 'theme/app_theme.dart';

// Where it all starts. Just spins up Flutter and hands off to our app widget.
void main() {
  runApp(const OKBusinessIntelligenceApp());
}

// Root widget — sets up the MaterialApp and points it at the shell screen.
// Keep this thin; app-wide config only, no actual UI logic belongs here.
class OKBusinessIntelligenceApp extends StatelessWidget {
  const OKBusinessIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // No "DEBUG" banner cluttering the corner while we're testing.
      debugShowCheckedModeBanner: false,
      // Shows up in the OS task switcher, not actually visible in-app.
      title: 'O-K Business Intelligence',
      // Dark theme only for now — all the colors/tokens live in AppTheme.
      theme: AppTheme.dark,
      // Shell screen owns nav/layout, so it's our real starting point.
      home: const ShellScreen(),
    );
  }
}