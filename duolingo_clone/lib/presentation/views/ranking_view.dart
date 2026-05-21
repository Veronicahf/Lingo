import 'package:flutter/material.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: const [
          _RankingHeader(),
          SizedBox(height: 20),
          _TrophyStrip(),
          SizedBox(height: 18),
          _RankingDividerLabel(
            text: 'ZONA DE ASCENSO',
            color: Color(0xFF8CD33C),
          ),
          SizedBox(height: 14),
          _RankingTable(),
          SizedBox(height: 18),
          _RankingDividerLabel(
            text: 'ZONA DE DESCENSO',
            color: Color(0xFFE95B5B),
          ),
          SizedBox(height: 14),
          _RankingTable(downZone: true),
        ],
      ),
    );
  }
}

class _RankingHeader extends StatelessWidget {
  const _RankingHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Division Oro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.schedule_rounded, color: Color(0xFF7B8893), size: 20),
            SizedBox(width: 6),
            Text(
              '4 DÍAS',
              style: TextStyle(
                color: Color(0xFF7B8893),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrophyStrip extends StatelessWidget {
  const _TrophyStrip();

  @override
  Widget build(BuildContext context) {
    const trophies = <_TrophyData>[
      _TrophyData(color: Color(0xFFB78C5C), iconColor: Color(0xFFFFE0B0)),
      _TrophyData(color: Color(0xFFC4CFD8), iconColor: Color(0xFFEDF2F6)),
      _TrophyData(color: Color(0xFFFFB400), iconColor: Color(0xFFFFF5C7), highlighted: true),
      _TrophyData(color: Color(0xFF627381), iconColor: Color(0xFF8D9AA6)),
      _TrophyData(color: Color(0xFF5A6875), iconColor: Color(0xFF7E8A95)),
    ];

    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: trophies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final trophy = trophies[index];
          return _TrophyCard(data: trophy);
        },
      ),
    );
  }
}

class _TrophyCard extends StatelessWidget {
  const _TrophyCard({required this.data});

  final _TrophyData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: data.highlighted ? 108 : 96,
        height: data.highlighted ? 108 : 96,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: data.highlighted ? const Color(0xFFFFC83D) : data.color.withValues(alpha: 0.65),
            width: 3,
          ),
        ),
        child: Icon(Icons.emoji_events_rounded, color: data.iconColor, size: data.highlighted ? 72 : 62),
      ),
    );
  }
}

class _RankingDividerLabel extends StatelessWidget {
  const _RankingDividerLabel({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_drop_up_rounded, color: color, size: 28),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          Icon(Icons.arrow_drop_up_rounded, color: color, size: 28),
        ],
      ),
    );
  }
}

class _RankingTable extends StatelessWidget {
  const _RankingTable({this.downZone = false});

  final bool downZone;

  @override
  Widget build(BuildContext context) {
    final entries = downZone ? _RankingEntry.samplesDown : _RankingEntry.samplesUp;

    return ListView.builder(
      itemCount: entries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final bool isHighlighted = entry.rank == 13;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFF26333B) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    color: isHighlighted ? Colors.white : const Color(0xFF7F8D97),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: entry.avatarColor,
                child: Text(
                  entry.avatarLetter,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.name,
                            style: TextStyle(
                              color: isHighlighted ? Colors.white : const Color(0xFFD8E1E7),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.exp} EXP',
                          style: TextStyle(
                            color: isHighlighted ? Colors.white : const Color(0xFF99A6AF),
                            fontSize: 18,
                            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(entry.flag, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          entry.level.toString(),
                          style: const TextStyle(color: Color(0xFF99A6AF), fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RankingEntry {
  const _RankingEntry({
    required this.rank,
    required this.name,
    required this.flag,
    required this.level,
    required this.exp,
    required this.avatarColor,
    required this.avatarLetter,
  });

  final int rank;
  final String name;
  final String flag;
  final int level;
  final int exp;
  final Color avatarColor;
  final String avatarLetter;

  static const samplesUp = <_RankingEntry>[
    _RankingEntry(rank: 10, name: 'J', flag: '🇧🇷', level: 8, exp: 45, avatarColor: Color(0xFFFFB347), avatarLetter: 'J'),
    _RankingEntry(rank: 11, name: 'Ali', flag: '🇺🇸', level: 3, exp: 45, avatarColor: Color(0xFFF3D7E7), avatarLetter: 'A'),
    _RankingEntry(rank: 12, name: 'Grace Ruiz', flag: '🇪🇸', level: 13, exp: 41, avatarColor: Color(0xFF4E7BC2), avatarLetter: 'G'),
    _RankingEntry(rank: 13, name: 'veronica', flag: '🇺🇸', level: 13, exp: 40, avatarColor: Color(0xFF55B0D6), avatarLetter: 'v'),
    _RankingEntry(rank: 14, name: 'Nando Ortiz', flag: '🇺🇸', level: 8, exp: 32, avatarColor: Color(0xFF52B7F2), avatarLetter: 'N'),
  ];

  static const samplesDown = <_RankingEntry>[
    _RankingEntry(rank: 15, name: 'Juan Pablo', flag: '🇺🇸', level: 8, exp: 31, avatarColor: Color(0xFFBF6B45), avatarLetter: 'J'),
    _RankingEntry(rank: 16, name: 'noi', flag: '🇺🇸', level: 4, exp: 27, avatarColor: Color(0xFF8DD13A), avatarLetter: 'N'),
    _RankingEntry(rank: 17, name: 'Sara', flag: '🇲🇽', level: 10, exp: 24, avatarColor: Color(0xFFDA6E72), avatarLetter: 'S'),
    _RankingEntry(rank: 18, name: 'Lina', flag: '🇨🇴', level: 6, exp: 18, avatarColor: Color(0xFF6C89D3), avatarLetter: 'L'),
  ];
}

class _TrophyData {
  const _TrophyData({
    required this.color,
    required this.iconColor,
    this.highlighted = false,
  });

  final Color color;
  final Color iconColor;
  final bool highlighted;
}