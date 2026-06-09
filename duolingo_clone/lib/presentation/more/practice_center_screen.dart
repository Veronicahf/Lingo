import 'package:flutter/material.dart';

import '../../core/under_construction_command.dart';
import '../../viewmodels/lesson_viewmodel.dart';
import '../lessons/active_lesson_screen.dart';
import '../../core/audio_service.dart';

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
        children: [
          _PracticeCard(
            title: 'Hablar',
            subtitle: 'Mejora tu pronunciación y fluidez',
            icon: Icons.mic_rounded,
            color: const Color(0xFF17C7A7),
            buttonLabel: 'COMENZAR',
            onTap: () => _navigateToPracticeLessonScreen(
              context,
              'speaking',
            ),
          ),
          const SizedBox(height: 16),
          _PracticeCard(
            title: 'Escuchar',
            subtitle: 'Entrena tu oído con frases cortas',
            icon: Icons.headphones_rounded,
            color: const Color(0xFFFF6464),
            buttonLabel: 'REPRODUCIR',
            onTap: () => _navigateToPracticeLessonScreen(
              context,
              'listening',
            ),
          ),
          const SizedBox(height: 16),
          _PracticeCard(
            title: 'Gramática',
            subtitle: 'Refuerza tus estructuras gramaticales',
            icon: Icons.text_fields_rounded,
            color: const Color(0xFFFFA31A),
            buttonLabel: 'PRACTICAR',
            onTap: () => _navigateToPracticeLessonScreen(
              context,
              'grammar',
            ),
          ),
          const SizedBox(height: 16),
          _PracticeCard(
            title: 'Traducción',
            subtitle: 'Mejora tu vocabulario con ejercicios',
            icon: Icons.style_rounded,
            color: const Color(0xFF58B8FF),
            buttonLabel: 'TRADUCIR',
            onTap: () => _navigateToPracticeLessonScreen(
              context,
              'translation',
            ),
          ),
          const SizedBox(height: 16),
          _PracticeCard(
            title: 'Cuentos',
            subtitle: 'Lee y escucha historias cortas',
            icon: Icons.menu_book_rounded,
            color: const Color(0xFFD89BFF),
            buttonLabel: 'ABRIR',
            onTap: () => const UnderConstructionCommand().execute(context),
          ),
        ],
      ),
    );
  }

  void _navigateToPracticeLessonScreen(
    BuildContext context,
    String category,
  ) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _PracticeLessonScreen(category: category),
      ),
    );
  }

  void _showErrorsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✨ ¡Repasaste todos tus errores! Excelente trabajo.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF17C7A7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Pantalla wrapper para cargar una lección de práctica con actividades filtradas.
class _PracticeLessonScreen extends StatefulWidget {
  const _PracticeLessonScreen({required this.category});

  final String category;

  @override
  State<_PracticeLessonScreen> createState() => _PracticeLessonScreenState();
}

class _PracticeLessonScreenState extends State<_PracticeLessonScreen> {
  late final LessonViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LessonViewModel();
    _viewModel.loadPracticeLesson(widget.category);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActiveLessonScreen(viewModel: _viewModel);
  }
}

class _PracticeCard extends StatefulWidget {
  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonLabel,
    this.onTap,
    this.isExpandable = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String buttonLabel;
  final VoidCallback? onTap;
  final bool isExpandable;

  @override
  State<_PracticeCard> createState() => _PracticeCardState();
}

class _PracticeCardState extends State<_PracticeCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded = false;
  late AnimationController _animationController;

  // Mock data for Palabras (learned words)
  static const List<String> _learnedWords = ['Apple', 'House', 'Cat'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (!widget.isExpandable) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 40),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.color),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: widget.isExpandable
                              ? _toggleExpanded
                              : (widget.onTap ?? () {}),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      widget.color.withValues(alpha: 0.55),
                                  offset: const Offset(0, 6),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.buttonLabel,
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
            // Palabras expansion section
            if (widget.isExpandable && _isExpanded) ...[
              const SizedBox(height: 18),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  _learnedWords.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WordCard(
                      word: _learnedWords[index],
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una palabra con icono de bocina para reproducir audio.
class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.color,
  });

  final String word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2E38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C3A43), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () {
              AudioService.instance.speak(word);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.volume_up_rounded,
                color: color,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
