import 'package:flutter/material.dart';

import '../../core/under_construction_command.dart';

class PracticeCenterScreen extends StatelessWidget {
  const PracticeCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101820),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Centro de práctica',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF9AA7B1)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: const [
          _PracticeCard(
            title: 'Hablar',
            subtitle: 'Mejora tu pronunciación y fluidez',
            icon: Icons.mic_rounded,
            color: Color(0xFF17C7A7),
            buttonLabel: 'COMENZAR',
          ),
          SizedBox(height: 16),
          _PracticeCard(
            title: 'Escuchar',
            subtitle: 'Entrena tu oído con frases cortas',
            icon: Icons.headphones_rounded,
            color: Color(0xFFFF6464),
            buttonLabel: 'REPRODUCIR',
          ),
          SizedBox(height: 16),
          _PracticeCard(
            title: 'Errores',
            subtitle: 'Repasa tus fallos recientes',
            icon: Icons.cached_rounded,
            color: Color(0xFFFFA31A),
            buttonLabel: 'VER REPASO',
          ),
          SizedBox(height: 16),
          _PracticeCard(
            title: 'Palabras',
            subtitle: 'Amplía vocabulario con tarjetas',
            icon: Icons.style_rounded,
            color: Color(0xFF58B8FF),
            buttonLabel: 'PRACTICAR',
          ),
          SizedBox(height: 16),
          _PracticeCard(
            title: 'Cuentos',
            subtitle: 'Lee y escucha historias cortas',
            icon: Icons.menu_book_rounded,
            color: Color(0xFFD89BFF),
            buttonLabel: 'ABRIR',
          ),
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF18242D),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF33414A), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
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
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: 0.55,
                    backgroundColor: const Color(0xFF35424C),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => const UnderConstructionCommand().execute(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.55),
                            offset: const Offset(0, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          color: Color(0xFF0C1520),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
