import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../layout/main_layout_screen.dart';

/// Pantalla de victoria que aparece al completar una leccion.
class LessonCompleteScreen extends StatelessWidget {
  /// Crea la pantalla de lección completada.
  const LessonCompleteScreen({super.key, this.xpGained = 10});

  /// Experiencia ganada en la lección.
  final int xpGained;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Lottie.asset('assets/lottie/Cat_in_a_rocket.json', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '¡Lección Completada!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'XP Ganada: +$xpGained',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF9FE33A),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const MainLayoutScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FE33A),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF5F8E13),
                        offset: Offset(0, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'CONTINUAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF09220A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}