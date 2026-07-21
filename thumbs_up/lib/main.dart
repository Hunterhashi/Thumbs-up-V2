import 'package:flutter/material.dart';
import 'package:thumbs_up/screens/launch_screen.dart';
import 'package:thumbs_up/theme/app_theme.dart';

void main() {
  runApp(const ThumbsUpApp());
}

class ThumbsUpApp extends StatelessWidget {
  const ThumbsUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thumbs Up',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LaunchScreen(),
    );
  }
}
