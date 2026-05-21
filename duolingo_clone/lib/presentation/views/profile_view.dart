import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../repositories/user_repository.dart';
import '../../viewmodels/profile_viewmodel.dart';

/// Pantalla de perfil del usuario que presenta su progreso y métricas principales.
///
/// Esta vista crea su propio ViewModel, lo escucha con `ListenableBuilder` y pinta los datos
/// del perfil provenientes del repositorio mock sin mezclar la lógica de carga con la UI.
class ProfileView extends StatefulWidget {
  /// Crea la pantalla de perfil.
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

/// Estado interno de [ProfileView] que instancia y libera el ViewModel de perfil.
class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _viewModel = ProfileViewModel(
    const MockUserRepository(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProfile();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final profile = _viewModel.profile;

        return Container(
          color: Colors.transparent,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              _ProfileHeader(username: profile?.username ?? 'Perfil'),
              const SizedBox(height: 18),
              const _ProfileHeroAvatar(),
              const SizedBox(height: 18),
              _ProfileHandleRow(
                handle: profile == null
                    ? 'CARGANDO PERFIL...'
                    : '@${profile.username.toUpperCase()} · ${profile.leagueName.toUpperCase()}',
              ),
              const SizedBox(height: 18),
              _ProfileStatsGrid(profile: profile),
              const SizedBox(height: 18),
              const _ProfileActionButton(label: 'AGREGA AMIGOS'),
              const SizedBox(height: 18),
              const _ProfilePromoCard(),
              const SizedBox(height: 24),
              const _ProfileSectionTitle(text: 'RESUMEN'),
              const SizedBox(height: 12),
              _ProfileSummaryGrid(profile: profile),
              const SizedBox(height: 24),
              const _ProfileSectionTitle(text: 'MEDALLAS MENSUALES'),
            ],
          ),
        );
      },
    );
  }
}

/// Cabecera superior del perfil con el nombre visible del usuario y accesos rápidos.
class _ProfileHeader extends StatelessWidget {
  /// Crea la cabecera usando el nombre del usuario.
  const _ProfileHeader({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Row(
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

/// Tarjeta decorativa que representa la fotografía o avatar principal del perfil.
class _ProfileHeroAvatar extends StatelessWidget {
  /// Crea el bloque visual del avatar.
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
      child: const Icon(
        Icons.person_rounded,
        size: 170,
        color: Color(0xFF3C3C3C),
      ),
    );
  }
}

/// Fila secundaria que muestra el identificador público del usuario y su división actual.
class _ProfileHandleRow extends StatelessWidget {
  /// Crea la fila del handle con texto dinámico.
  const _ProfileHandleRow({required this.handle});

  final String handle;

  @override
  Widget build(BuildContext context) {
    return Text(
      handle,
      style: const TextStyle(
        color: Color(0xFF7D8992),
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Cuadrícula breve de métricas principales del perfil, alimentada por el ViewModel.
class _ProfileStatsGrid extends StatelessWidget {
  /// Crea la cuadrícula principal a partir del perfil cargado.
  const _ProfileStatsGrid({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final streakValue = profile == null ? '...' : '${profile!.streakDays} días';
    final xpValue = profile == null ? '...' : '${profile!.totalXp} EXP';
    final divisionValue = profile == null ? '...' : profile!.leagueName;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatTile(icon: '🔥', value: streakValue, label: 'Racha'),
        _StatTile(icon: '⚡', value: xpValue, label: 'EXP'),
        _StatTile(icon: '🏆', value: divisionValue, label: 'División'),
      ],
    );
  }
}

/// Bloque de una métrica con icono, valor y etiqueta descriptiva.
class _StatTile extends StatelessWidget {
  /// Crea una tarjeta de estadística compacta.
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AA7B1),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Botón principal reutilizable de la pantalla de perfil.
class _ProfileActionButton extends StatelessWidget {
  /// Crea el botón de acción principal.
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
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

/// Tarjeta promocional que invita a conectar el puntaje del usuario con LinkedIn.
class _ProfilePromoCard extends StatelessWidget {
  /// Crea la tarjeta promocional del perfil.
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

/// Título de sección reutilizable para dividir visualmente el contenido del perfil.
class _ProfileSectionTitle extends StatelessWidget {
  /// Crea el título de una sección con un texto fijo de contexto.
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

/// Cuadrícula de resumen con datos secundarios del perfil provenientes del ViewModel.
class _ProfileSummaryGrid extends StatelessWidget {
  /// Crea la cuadrícula de resumen con valores dinámicos.
  const _ProfileSummaryGrid({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final gemsValue = profile == null ? '...' : '${profile!.gems} gemas';
    final heartsValue = profile == null
        ? '...'
        : profile!.hearts == -1
            ? 'Corazones infinitos'
            : '${profile!.hearts} corazones';
    final usernameValue = profile == null ? '...' : profile!.username;
    final leagueValue = profile == null ? '...' : profile!.leagueName;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 2.1,
      ),
      children: [
        _SummaryTile(icon: '💎', value: gemsValue),
        _SummaryTile(icon: '💗', value: heartsValue),
        _SummaryTile(icon: '👤', value: usernameValue),
        _SummaryTile(icon: '🏆', value: leagueValue),
      ],
    );
  }
}

/// Tarjeta compacta usada para resumir un dato adicional del perfil.
class _SummaryTile extends StatelessWidget {
  /// Crea una tarjeta resumen con icono y texto principal.
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