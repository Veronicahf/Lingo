import 'package:flutter/material.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: const [
          Text(
            'Novedades',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 26),
          _NewsPromoCard(),
          SizedBox(height: 22),
          Divider(color: Color(0xFF2B3840), height: 1),
          SizedBox(height: 18),
          _NewsFeedItem(
            userName: 'veronica',
            timeLabel: '1 m',
            message: '¡Completó una lección sin errores!',
            reactionCount: '0',
            primaryColor: Color(0xFF37D0E1),
            accentColor: Color(0xFF92E34B),
            initials: 'V',
          ),
          SizedBox(height: 22),
          Divider(color: Color(0xFF2B3840), height: 1),
          SizedBox(height: 18),
          _NewsQuoteCard(),
        ],
      ),
    );
  }
}

class _NewsPromoCard extends StatelessWidget {
  const _NewsPromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF24A0E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 210,
            child: Text(
              '¡Celebra tus logros\ncon tus amigos!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Text(
              'AGREGA AMIGOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1C97D0),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsFeedItem extends StatelessWidget {
  const _NewsFeedItem({
    required this.userName,
    required this.timeLabel,
    required this.message,
    required this.reactionCount,
    required this.primaryColor,
    required this.accentColor,
    required this.initials,
  });

  final String userName;
  final String timeLabel;
  final String message;
  final String reactionCount;
  final Color primaryColor;
  final Color accentColor;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2C3A43),
          child: Text(
            initials,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeLabel,
                style: const TextStyle(
                  color: Color(0xFF86939D),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _SmallActionChip(
                    icon: Icons.favorite_border_rounded,
                    label: reactionCount,
                  ),
                  const SizedBox(width: 12),
                  const _SmallActionChip(
                    icon: Icons.ios_share_rounded,
                    label: '',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Icon(Icons.flutter_dash_rounded, color: primaryColor, size: 48),
        ),
      ],
    );
  }
}

class _SmallActionChip extends StatelessWidget {
  const _SmallActionChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: label.isEmpty ? 54 : 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A4952), width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

class _NewsQuoteCard extends StatelessWidget {
  const _NewsQuoteCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF26333B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'He was awarded a medal for\nhis bravery!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '¡Recibió una medalla por su valentía!',
                  style: TextStyle(
                    color: Color(0xFF8F9DA7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 82,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFF9FE33A),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.flutter_dash_rounded, color: Color(0xFF0E1C24), size: 60),
        ),
      ],
    );
  }
}