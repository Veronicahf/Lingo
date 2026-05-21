import 'package:flutter/material.dart';

import '../more/practice_center_screen.dart';
import '../more/sounds_screen.dart';
import '../more/video_call_screen.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          const Text(
            'Más',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _MoreOptionCard(
            title: 'Sonidos',
            subtitle: 'Practica vocales y consonantes',
            icon: Icons.graphic_eq_rounded,
            accentColor: const Color(0xFF52BDF7),
            iconBackground: const Color(0xFF1F86C1),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SoundsScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _MoreOptionCard(
            title: 'Centro de Práctica',
            subtitle: 'Ejercicios guiados y tarjetas',
            icon: Icons.fitness_center_rounded,
            accentColor: const Color(0xFFFFC24A),
            iconBackground: const Color(0xFFDA8A00),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PracticeCenterScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _MoreOptionCard(
            title: 'Videollamada',
            subtitle: 'Lecciones con personajes',
            icon: Icons.video_call_rounded,
            accentColor: const Color(0xFFB87CFF),
            iconBackground: const Color(0xFF6730A8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideoCallScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoreOptionCard extends StatelessWidget {
  const _MoreOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.iconBackground,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A272F),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
          border: Border.all(color: const Color(0xFF33414A), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9AA7B1),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA7B1), size: 30),
          ],
        ),
      ),
    );
  }
}