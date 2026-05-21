import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: const [
          _ProfileHeader(),
          SizedBox(height: 18),
          _ProfileHeroAvatar(),
          SizedBox(height: 18),
          _ProfileHandleRow(),
          SizedBox(height: 18),
          _ProfileStatsGrid(),
          SizedBox(height: 18),
          _ProfileActionButton(label: 'AGREGA AMIGOS'),
          SizedBox(height: 18),
          _ProfilePromoCard(),
          SizedBox(height: 24),
          _ProfileSectionTitle(text: 'RESUMEN'),
          SizedBox(height: 12),
          _ProfileSummaryGrid(),
          SizedBox(height: 24),
          _ProfileSectionTitle(text: 'MEDALLAS MENSUALES'),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'veronica',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        Row(
          children: [
            Icon(Icons.ios_share_rounded, color: Color(0xFF9AA7B1), size: 30),
            SizedBox(width: 18),
            Icon(Icons.settings_rounded, color: Color(0xFF9AA7B1), size: 30),
          ],
        ),
      ],
    );
  }
}

class _ProfileHeroAvatar extends StatelessWidget {
  const _ProfileHeroAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD5D5D5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.person_rounded, size: 170, color: Color(0xFF3C3C3C)),
    );
  }
}

class _ProfileHandleRow extends StatelessWidget {
  const _ProfileHandleRow();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '@VEROHF18 · SE UNIÓ EN 2020',
      style: TextStyle(
        color: Color(0xFF7D8992),
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _ProfileStatsGrid extends StatelessWidget {
  const _ProfileStatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatTile(icon: '🇺🇸', value: 'Cursos', label: '1'),
        _StatTile(icon: '🔥', value: 'Siguiendo', label: '0'),
        _StatTile(icon: '⭐', value: 'Seguidores', label: '0'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9AA7B1), fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A4952), width: 3),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'AGREGA AMIGOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePromoCard extends StatelessWidget {
  const _ProfilePromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3038),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡Agrega tu Score de\nDuolingo a LinkedIn!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF5DBDF4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'AGRÉGALO AHORA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0D2736),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7D8992),
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ProfileSummaryGrid extends StatelessWidget {
  const _ProfileSummaryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 2.1,
      ),
      children: const [
        _SummaryTile(icon: '🔥', value: '1 día'),
        _SummaryTile(icon: '🇺🇸', value: '13'),
        _SummaryTile(icon: '🏆', value: 'Oro'),
        _SummaryTile(icon: '⚡', value: '2555 EXP'),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.icon, required this.value});

  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2830),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}