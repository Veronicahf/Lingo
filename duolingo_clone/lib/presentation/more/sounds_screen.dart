import 'package:flutter/material.dart';

import '../../core/under_construction_command.dart';

class SoundsScreen extends StatelessWidget {
  const SoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_SoundItem>[
      const _SoundItem('a', 'hot'),
      const _SoundItem('æ', 'cat'),
      const _SoundItem('ʌ', 'but'),
      const _SoundItem('ɛ', 'bed'),
      const _SoundItem('ei', 'say'),
      const _SoundItem('ə', 'bird'),
      const _SoundItem('ɪ', 'ship'),
      const _SoundItem('i', 'sheep'),
      const _SoundItem('ə', 'about'),
      const _SoundItem('ou', 'boat'),
      const _SoundItem('ʊ', 'foot'),
      const _SoundItem('u', 'food'),
      const _SoundItem('au', 'cow'),
      const _SoundItem('ai', 'time'),
      const _SoundItem('ɔi', 'boy'),
      const _SoundItem('b', 'book'),
      const _SoundItem('tʃ', 'chair'),
      const _SoundItem('d', 'day'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            const Text(
              'Prácticar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF4DB8EF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Mejora tu pronunciación del inglés!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entrena tu oído y aprende a pronunciar palabras en inglés',
                    style: TextStyle(color: Colors.white, fontSize: 16, height: 1.35),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => const UnderConstructionCommand().execute(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CC8F5),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            offset: const Offset(0, 8),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'EMPEZAR LECCIÓN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F1B22),
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
            const SizedBox(height: 22),
            const Text(
              'Vocales',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 15,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _SoundCard(item: item);
              },
            ),
            const SizedBox(height: 22),
            const Text(
              'Consonantes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final item = items[15 + index];
                return _SoundCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundItem {
  const _SoundItem(this.phonetic, this.example);

  final String phonetic;
  final String example;
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({required this.item});

  final _SoundItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => const UnderConstructionCommand().execute(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A272F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF36444D), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.phonetic, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(item.example, style: const TextStyle(color: Color(0xFF8F9DA7), fontSize: 14)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: 0.45,
                backgroundColor: const Color(0xFF37444E),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6CC8F5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
