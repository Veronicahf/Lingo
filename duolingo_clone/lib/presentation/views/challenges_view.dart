import 'package:flutter/material.dart';

import '../../models/challenge.dart';
import '../../viewmodels/challenges_viewmodel.dart';

/// Pantalla de desafios que presenta tareas, cofres y recompensas desde datos estructurados.
///
/// Esta vista escucha al [ChallengesViewModel] y renderiza cada desafio a partir de la lista
/// obtenida del repositorio, evitando tarjetas y textos quemados dentro del widget tree.
class ChallengesView extends StatefulWidget {
  /// Crea la pantalla de desafios.
  const ChallengesView({super.key});

  @override
  State<ChallengesView> createState() => _ChallengesViewState();
}

/// Estado interno de [ChallengesView] encargado de cargar y liberar la ViewModel.
class _ChallengesViewState extends State<ChallengesView> {
  late final ChallengesViewModel _viewModel = ChallengesViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadChallenges();
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
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: [
          const SizedBox(height: 18),
          const _ChallengesHeader(),
          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return _ChallengesList(challenges: _viewModel.challenges);
            },
          ),
        ],
      ),
    );
  }
}

/// Cabecera superior de la pantalla de desafios.
class _ChallengesHeader extends StatelessWidget {
  /// Crea la cabecera principal de desafios.
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

/// Lista de desafios renderizada desde el ViewModel.
class _ChallengesList extends StatelessWidget {
  /// Crea la lista visual de desafios.
  const _ChallengesList({required this.challenges});

  final List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < challenges.length; index++) ...[
          _ChallengeSection(challenge: challenges[index]),
          if (index != challenges.length - 1) ...[
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF2B3840), height: 1),
            const SizedBox(height: 24),
          ],
        ],
      ],
    );
  }
}

/// Seccion visual de un desafio individual.
class _ChallengeSection extends StatelessWidget {
  /// Crea una tarjeta de desafio a partir del modelo [Challenge].
  const _ChallengeSection({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    if (challenge.isLocked) {
      return _LockedChallengePreview(
        title: challenge.eyebrow ?? 'A continuación',
        subtitle: challenge.lockedSubtitle ?? challenge.title,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (challenge.eyebrow ?? '').toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                challenge.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              _ProgressBar(
                value: challenge.progressValue,
                color: challenge.progressColor ?? const Color(0xFF4A5863),
                label: challenge.progressLabel,
              ),
              if (challenge.actionLabel != null && challenge.actionIcon != null) ...[
                const SizedBox(height: 18),
                _OutlinedActionButton(label: challenge.actionLabel!, icon: challenge.actionIcon!),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        _ChallengeChest(style: challenge.chestStyle),
      ],
    );
  }
}

/// Barra de progreso reutilizable para mostrar avance de un desafio.
class _ProgressBar extends StatelessWidget {
  /// Crea una barra con valor, color y etiqueta.
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

/// Boton de contorno reutilizable para acciones de desafio.
class _OutlinedActionButton extends StatelessWidget {
  /// Crea el boton de accion con icono y texto.
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

/// Cofre visual asociado a un desafio.
class _ChallengeChest extends StatelessWidget {
  /// Crea el cofre segun su variante visual.
  const _ChallengeChest({required this.style});

  final ChallengeChestStyle style;

  @override
  Widget build(BuildContext context) {
    final bool isFriend = style == ChallengeChestStyle.friend;
    final bool isDaily = style == ChallengeChestStyle.daily;
    final Color chestColor = isFriend
        ? const Color(0xFFFFD23D)
        : isDaily
            ? const Color(0xFFF2A12B)
            : const Color(0xFF5C6B76);
    final Color accentColor = isFriend
        ? const Color(0xFFB96CFF)
        : isDaily
            ? const Color(0xFFFFD9B0)
            : const Color(0xFF94A1AB);

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
              color: isFriend
                  ? const Color(0xFF8D43D9)
                  : isDaily
                      ? const Color(0xFFCD6E14)
                      : const Color(0xFF43515A),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Icon(
            style == ChallengeChestStyle.locked ? Icons.lock_rounded : Icons.groups_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            size: 28,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta bloqueada usada para los desafios proximos.
class _LockedChallengePreview extends StatelessWidget {
  /// Crea la vista previa de un desafio bloqueado.
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