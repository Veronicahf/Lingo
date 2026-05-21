import 'package:flutter/material.dart';

import 'presentation/onboarding/welcome_screen.dart';

class DuolingoCloneApp extends StatelessWidget {
  const DuolingoCloneApp({super.key});

  static const Color _backgroundColor = Color(0xFF101820);
  static const Color _surfaceColor = Color(0xFF161F28);
  static const Color _activeColor = Color(0xFF55C7FF);
  static const Color _inactiveColor = Color(0xFF6E7A85);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Duolingo Clone',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: _backgroundColor,
        colorScheme: const ColorScheme.dark(
          background: _backgroundColor,
          surface: _surfaceColor,
          primary: _activeColor,
          secondary: Color(0xFFFFC83D),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ).copyWith(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _backgroundColor,
          selectedItemColor: _activeColor,
          unselectedItemColor: _inactiveColor,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}