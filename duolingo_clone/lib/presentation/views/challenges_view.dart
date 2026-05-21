import 'package:flutter/material.dart';

class ChallengesView extends StatelessWidget {
  const ChallengesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: const [
          SizedBox(height: 18),
          _ChallengesHeader(),
          SizedBox(height: 18),
          _ChallengeSection(
            eyebrow: 'Desafío entre amigos',
            title: 'Sigue a tu primer amigo',
            progress: '0 / 1',
            progressValue: 0.0,
            actionLabel: 'Encuentra a tus amigos',
            actionIcon: Icons.person_add_alt_1_rounded,
            chestStyle: _ChestStyle.friend,
          ),
          SizedBox(height: 24),
          Divider(color: Color(0xFF2B3840), height: 1),
          SizedBox(height: 24),
          _ChallengeSection(
            eyebrow: 'Desafío del día',
            title: 'Empieza una racha',
            progress: '1 / 1',
            progressValue: 1.0,
            progressColor: Color(0xFFFF5CB8),
            chestStyle: _ChestStyle.daily,
          ),
          SizedBox(height: 24),
          Divider(color: Color(0xFF2B3840), height: 1),
          SizedBox(height: 24),
          _LockedChallengePreview(
            title: 'A continuación',
            subtitle: 'Se revelará en 6 días',
          ),
          SizedBox(height: 14),
          _LockedChallengePreview(
            title: 'A continuación',
            subtitle: 'Se revelará en 6 días',
          ),
        ],
      ),
    );
  }
}

class _ChallengesHeader extends StatelessWidget {
  const _ChallengesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF9A73D4),
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desafíos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Completa desafíos y recibe\nrecompensas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 110,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFF9EEB2A),
              size: 64,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChestStyle { friend, daily }

class _ChallengeSection extends StatelessWidget {
  const _ChallengeSection({
    required this.eyebrow,
    required this.title,
    required this.progress,
    required this.progressValue,
    this.progressColor = const Color(0xFF4A5863),
    this.actionLabel,
    this.actionIcon,
    required this.chestStyle,
  });

  final String eyebrow;
  final String title;
  final String progress;
  final double progressValue;
  final Color progressColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final _ChestStyle chestStyle; 

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              _ProgressBar(value: progressValue, color: progressColor, label: progress),
              if (actionLabel != null && actionIcon != null) ...[
                const SizedBox(height: 18),
                _OutlinedActionButton(label: actionLabel!, icon: actionIcon!),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        _ChallengeChest(style: chestStyle),
      ],
    );
  }
}


class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.color,
    required this.label,
  });

  final double value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF3D4A54),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        FractionallySizedBox(
          widthFactor: value,
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3C4A54), width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeChest extends StatelessWidget {
  const _ChallengeChest({required this.style});

  final _ChestStyle style;

  @override
  Widget build(BuildContext context) {
    final bool isFriend = style == _ChestStyle.friend;
    final Color chestColor = isFriend ? const Color(0xFFFFD23D) : const Color(0xFFF2A12B);
    final Color accentColor = isFriend ? const Color(0xFFB96CFF) : const Color(0xFFFFD9B0);

    return Container(
      width: 84,
      height: 84,
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: chestColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(width: 14, color: accentColor),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 22,
            child: Container(height: 12, color: accentColor),
          ),
          Container(
            width: 26,
            height: 16,
            decoration: BoxDecoration(
              color: isFriend ? const Color(0xFF8D43D9) : const Color(0xFFCD6E14),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Icon(
            isFriend ? Icons.groups_rounded : Icons.lock_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _LockedChallengePreview extends StatelessWidget {
  const _LockedChallengePreview({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF98A5AF),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF495760),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF5C6B76),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.lock_rounded, color: Color(0xFF94A1AB), size: 32),
        ),
      ],
    );
  }
}