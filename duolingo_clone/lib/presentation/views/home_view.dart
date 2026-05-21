import 'package:flutter/material.dart';

import '../lessons/active_lesson_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const Color _backgroundColor = Color(0xFF101820);
  static const Color _stageCardColor = Color(0xFFCE78F8);
  static const Color _stageCardShadow = Color(0xFF8F4CB4);
  static const Color _activeLessonColor = Color(0xFFC775F4);
  static const Color _activeLessonShadow = Color(0xFF7A4AA8);
  static const Color _lockedLessonColor = Color(0xFF495560);
  static const Color _lockedIconColor = Color(0xFF74818B);
  static const Color _flagColor = Color(0xFFFFFFFF);
  static const Color _fireColor = Color(0xFFFFB42B);
  static const Color _gemColor = Color(0xFF48B9FF);
  static const Color _heartColor = Color(0xFFF88CD4);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              SizedBox(height: 10),
              _TopStatsBar(),
              SizedBox(height: 14),
              _StageBanner(),
              SizedBox(height: 18),
              _LearningPath(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopStatsBar extends StatelessWidget {
  const _TopStatsBar();

  static const Color _flagColor = Color(0xFFFFFFFF);
  static const Color _fireColor = Color(0xFFFFB42B);
  static const Color _gemColor = Color(0xFF48B9FF);
  static const Color _heartColor = Color(0xFFF88CD4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: const [
          Expanded(
            child: _TopStatItem(
              icon: Icons.flag_rounded,
              iconColor: _flagColor,
              label: '13',
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.local_fire_department_rounded,
              iconColor: _fireColor,
              label: '1',
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.diamond_rounded,
              iconColor: _gemColor,
              label: '931',
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.favorite_rounded,
              iconColor: _heartColor,
              label: '∞',
              useInfinityLabel: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStatItem extends StatelessWidget {
  const _TopStatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.useInfinityLabel = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool useInfinityLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 25),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: iconColor,
            fontSize: useInfinityLabel ? 22 : 17,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StageBanner extends StatelessWidget {
  const _StageBanner();

  static const Color _cardColor = Color(0xFFCE78F8);
  static const Color _shadowColor = Color(0xFF8F4CB4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: _shadowColor,
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ETAPA 2, SECCIÓN 7',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Habla de comidas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 68,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                border: Border(
                  left: BorderSide(color: Colors.black.withValues(alpha: 0.10), width: 2),
                ),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningPath extends StatelessWidget {
  const _LearningPath();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1380,
      child: Stack(
        children: const [
          _PathLesson(
            top: 18,
            left: 140,
            size: 92,
            icon: Icons.cached_rounded,
            active: true,
          ),
          _PathLesson(
            top: 138,
            left: 86,
            size: 84,
            icon: Icons.star_rounded,
          ),
          _PathLesson(
            top: 260,
            left: 48,
            size: 84,
            icon: Icons.videocam_rounded,
          ),
          _PathLesson(
            top: 250,
            right: 36,
            size: 120,
            icon: Icons.person_rounded,
            character: true,
          ),
          _PathLesson(
            top: 400,
            left: 96,
            size: 84,
            icon: Icons.menu_book_rounded,
          ),
          _PathLesson(
            top: 530,
            left: 142,
            size: 84,
            icon: Icons.headphones_rounded,
          ),
          _PathLesson(
            top: 680,
            right: 58,
            size: 88,
            icon: Icons.videocam_rounded,
          ),
          _PathLesson(
            top: 830,
            left: 34,
            size: 112,
            icon: Icons.person_rounded,
            character: true,
          ),
          _PathLesson(
            top: 970,
            right: 42,
            size: 82,
            icon: Icons.star_rounded,
          ),
          _PathLesson(
            top: 1088,
            left: 176,
            size: 88,
            icon: Icons.star_rounded,
          ),
          _PathLesson(
            top: 1208,
            left: 118,
            size: 90,
            icon: Icons.lock_rounded,
          ),
        ],
      ),
    );
  }
}

class _PathLesson extends StatelessWidget {
  const _PathLesson({
    required this.top,
    this.left,
    this.right,
    required this.size,
    required this.icon,
    this.active = false,
    this.character = false,
  });

  final double top;
  final double? left;
  final double? right;
  final double size;
  final IconData icon;
  final bool active;
  final bool character;

  static const Color _activeColor = Color(0xFFC775F4);
  static const Color _activeShadow = Color(0xFF7A4AA8);
  static const Color _lockedColor = Color(0xFF495560);
  static const Color _lockedIconColor = Color(0xFF74818B);

  @override
  Widget build(BuildContext context) {
    final Widget child = character
        ? _CharacterNode(
            size: size,
            active: active,
          )
        : _LessonNode(
            size: size,
            icon: icon,
            active: active,
          );

    return Positioned(
      top: top,
      left: left,
      right: right,
      child: child,
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.size,
    required this.icon,
    required this.active,
  });

  final double size;
  final IconData icon;
  final bool active;

  static const Color _activeColor = Color(0xFFC775F4);
  static const Color _activeShadow = Color(0xFF7A4AA8);
  static const Color _lockedColor = Color(0xFF495560);
  static const Color _lockedIconColor = Color(0xFF74818B);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = active ? _activeColor : _lockedColor;
    final Color iconColor = active ? Colors.white : _lockedIconColor;
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: active ? _activeShadow : Colors.black.withValues(alpha: 0.14),
        offset: const Offset(0, 8),
        blurRadius: 0,
      ),
    ];

    final lessonContainer = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: shadows,
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.42),
      ),
    );

    if (!active) {
      return lessonContainer;
    }

    return GestureDetector(
      // TODO: Extraer a un Command (ej. StartLessonCommand) cuando se implemente HomeViewModel.
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const ActiveLessonScreen(),
          ),
        );
      },
      child: lessonContainer,
    );
  }
}

class _CharacterNode extends StatelessWidget {
  const _CharacterNode({
    required this.size,
    required this.active,
  });

  final double size;
  final bool active;

  static const Color _activeColor = Color(0xFFC775F4);
  static const Color _lockedColor = Color(0xFF495560);
  static const Color _lockedIconColor = Color(0xFF74818B);

  @override
  Widget build(BuildContext context) {
    final Color bodyColor = active ? _activeColor : _lockedColor;
    final Color faceColor = active ? Colors.white : _lockedIconColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              color: bodyColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  offset: const Offset(0, 8),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          Positioned(
            top: size * 0.22,
            child: Icon(Icons.person_rounded, color: faceColor.withValues(alpha: 0.78), size: size * 0.36),
          ),
          Positioned(
            bottom: size * 0.12,
            child: Icon(Icons.stars_rounded, color: faceColor.withValues(alpha: 0.55), size: size * 0.26),
          ),
        ],
      ),
    );
  }
}