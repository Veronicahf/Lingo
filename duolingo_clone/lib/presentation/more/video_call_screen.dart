import 'package:flutter/material.dart';

import '../../core/under_construction_command.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF9D6BE7), Color(0xFF2A0F4E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Videollamada',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E4FE0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            offset: const Offset(0, 10),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_rounded, color: Color(0xFFE2C3FF), size: 120),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF120A24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Lily',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () => const UnderConstructionCommand().execute(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            offset: const Offset(0, 8),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'PRUÉBALO POR 0,00 MXN',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF3C1F75), fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'Recientes',
                style: TextStyle(color: Color(0xFF7D8992), fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 14),
            _RecentCallCard(
              title: 'Aburrida en el centro comercial',
              date: '10/3/25',
              badge: 'NUEVAS',
            ),
            const SizedBox(height: 14),
            _RecentCallCard(
              title: 'Practicar con Lily',
              date: '09/3/25',
              badge: 'NUEVAS',
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCallCard extends StatelessWidget {
  const _RecentCallCard({
    required this.title,
    required this.date,
    required this.badge,
  });

  final String title;
  final String date;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: () => const UnderConstructionCommand().execute(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A272F),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.mail_outline_rounded, color: Color(0xFF9AA7B1), size: 18),
                            const SizedBox(width: 6),
                            Text(date, style: const TextStyle(color: Color(0xFF9AA7B1), fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5151),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 190,
                decoration: BoxDecoration(
                  color: const Color(0xFF53217F),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.play_arrow_rounded, color: Color(0xFF5A24A1), size: 34),
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
