import 'package:flutter/material.dart';
import 'screens/shell_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const OKBusinessIntelligenceApp());
}

class OKBusinessIntelligenceApp extends StatelessWidget {
  const OKBusinessIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'O-K Business Intelligence',
      theme: AppTheme.dark,
      home: const ShellScreen(),
    );
  }
}