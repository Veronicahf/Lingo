import 'package:flutter/material.dart';

import '../../models/ranking_user.dart';
import '../../viewmodels/ranking_viewmodel.dart';

/// Pantalla de ranking que presenta la division y la tabla de posiciones desde datos estructurados.
///
/// Esta vista escucha al [RankingViewModel] y construye las filas del leaderboard sin usuarios
/// escritos directamente en el widget tree.
class RankingView extends StatefulWidget {
  /// Crea la pantalla de ranking.
  const RankingView({super.key});

  @override
  State<RankingView> createState() => _RankingViewState();
}

/// Estado interno de [RankingView] encargado de cargar y liberar el ViewModel.
class _RankingViewState extends State<RankingView> {
  late final RankingViewModel _viewModel = RankingViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadRankingUsers();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          const _RankingHeader(),
          const SizedBox(height: 20),
          const _TrophyStrip(),
          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              final users = _viewModel.rankingUsers;
              final currentIndex = _viewModel.currentUserIndex;

              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final topUsers = currentIndex >= 0 ? users.sublist(0, currentIndex + 1) : users;
              final bottomUsers = currentIndex >= 0 && currentIndex + 1 < users.length
                  ? users.sublist(currentIndex + 1)
                  : <RankingUser>[];

              return Column(
                children: [
                  const _RankingDividerLabel(
                    text: 'ZONA DE ASCENSO',
                    color: Color(0xFF8CD33C),
                  ),
                  const SizedBox(height: 14),
                  _RankingTable(entries: topUsers, startRank: 1),
                  if (bottomUsers.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const _RankingDividerLabel(
                      text: 'ZONA DE DESCENSO',
                      color: Color(0xFFE95B5B),
                    ),
                    const SizedBox(height: 14),
                    _RankingTable(entries: bottomUsers, startRank: topUsers.length + 1),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Cabecera superior del ranking con division y dias restantes.
class _RankingHeader extends StatelessWidget {
  /// Crea la cabecera de ranking.
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

/// Banda horizontal de trofeos que conserva el contexto visual del ranking.
class _TrophyStrip extends StatelessWidget {
  /// Crea la banda de trofeos.
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

/// Tarjeta individual del carrusel de trofeos.
class _TrophyCard extends StatelessWidget {
  /// Crea una tarjeta de trofeo.
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

/// Etiqueta separadora para las zonas de ascenso y descenso.
class _RankingDividerLabel extends StatelessWidget {
  /// Crea un separador con texto y color.
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

/// Tabla de posiciones construida a partir de una lista de usuarios del ranking.
class _RankingTable extends StatelessWidget {
  /// Crea la tabla con entradas y numero inicial de ranking.
  const _RankingTable({
    required this.entries,
    required this.startRank,
  });

  final List<RankingUser> entries;
  final int startRank;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final int rank = startRank + index;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: entry.isCurrentUser ? const Color(0xFF26333B) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: entry.isCurrentUser ? Colors.white : const Color(0xFF7F8D97),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _RankingAvatar(user: entry),
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
                              color: entry.isCurrentUser ? Colors.white : const Color(0xFFD8E1E7),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.xp} XP',
                          style: TextStyle(
                            color: entry.isCurrentUser ? Colors.white : const Color(0xFF99A6AF),
                            fontSize: 18,
                            fontWeight: entry.isCurrentUser ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.isCurrentUser ? 'Tu posición actual' : 'Competidor activo',
                      style: const TextStyle(
                        color: Color(0xFF99A6AF),
                        fontSize: 15,
                      ),
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

/// Avatar reutilizable para el usuario del ranking.
class _RankingAvatar extends StatelessWidget {
  /// Crea el avatar del usuario con fallback por inicial.
  const _RankingAvatar({required this.user});

  final RankingUser user;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.network(
          user.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: user.isCurrentUser ? const Color(0xFF55B0D6) : const Color(0xFF44525C),
              alignment: Alignment.center,
              child: Text(
                user.name.isNotEmpty ? user.name.characters.first.toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Datos de un trofeo del carrusel superior.
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
