import 'package:flutter/material.dart';

import '../../core/under_construction_command.dart';
import '../../models/streak_calendar_day.dart';
import '../../viewmodels/streak_viewmodel.dart';
import '../widgets/mascot_animation_widget.dart';

/// Pantalla completa de racha que replica la experiencia de Duolingo para racha personal y entre amigos.
///
/// Esta pantalla utiliza un ViewModel mock para exponer los datos visuales del calendario,
/// el estado de protectores y el contenido de la pestaña social sin hardcodear la UI.
class StreakScreen extends StatefulWidget {
  /// Crea la pantalla de racha.
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

/// Estado interno de [StreakScreen] que carga el ViewModel y libera sus recursos.
class _StreakScreenState extends State<StreakScreen> {
  late final StreakViewModel _viewModel = StreakViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadStreakData();
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
        return Scaffold(
          backgroundColor: const Color(0xFF101820),
          appBar: _StreakTopBar(
            daysLabel: '${_viewModel.streakDays} días',
            onClose: () => Navigator.of(context).pop(),
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                _StreakTabs(personalLabel: _viewModel.personalTabLabel, friendsLabel: _viewModel.friendsTabLabel),
                Expanded(
                  child: TabBarView(
                    children: [
                      _PersonalStreakTab(viewModel: _viewModel),
                      _FriendsStreakTab(viewModel: _viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Barra superior personalizada para la pantalla de racha.
class _StreakTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Crea la barra con el botón de cierre, el contador de días y la acción de compartir.
  const _StreakTopBar({
    required this.daysLabel,
    required this.onClose,
  });

  final String daysLabel;
  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF101820),
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 110,
      centerTitle: true,
      titleSpacing: 0,
      title: Text(
        daysLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      leading: IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 34),
      ),
      leadingWidth: 56,
      actions: [
        IconButton(
          onPressed: () => const UnderConstructionCommand().execute(context),
          icon: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 30),
        ),
      ],
    );
  }
}

/// Encabezado con pestañas para alternar entre la experiencia personal y la social.
class _StreakTabs extends StatelessWidget {
  /// Crea la barra de tabs con dos opciones.
  const _StreakTabs({
    required this.personalLabel,
    required this.friendsLabel,
  });

  final String personalLabel;
  final String friendsLabel;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorColor: const Color(0xFF27A8E0),
      indicatorWeight: 4,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF667580),
      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      tabs: [
        Tab(text: personalLabel),
        Tab(text: friendsLabel),
      ],
    );
  }
}

/// Pestaña personal con calendario y protectores de racha.
class _PersonalStreakTab extends StatelessWidget {
  /// Crea la vista personal a partir del ViewModel.
  const _PersonalStreakTab({required this.viewModel});

  final StreakViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF151F27),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF27323B), width: 2),
          ),
          alignment: Alignment.center,
          child: const MascotAnimationWidget(
            assetPath: 'assets/lottie/cat_sleeping.json',
            width: 220,
            height: 220,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF18222B),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF2B3741), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFF26323C),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.ac_unit_rounded, color: Color(0xFF8CD9FF), size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.protectorsTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewModel.protectorsDescription,
                      style: const TextStyle(
                        color: Color(0xFF9AA7B1),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: viewModel.streakProtectors > 0,
                onChanged: (_) => const UnderConstructionCommand().execute(context),
                activeColor: const Color(0xFF27A8E0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Calendario de racha',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF162129),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF33414A), width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.chevron_left_rounded, color: Color(0xFF9AA7B1), size: 34),
                  const Text(
                    'mayo de 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA7B1), size: 34),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CalendarWeekday(label: 'D'),
                  _CalendarWeekday(label: 'L'),
                  _CalendarWeekday(label: 'Ma'),
                  _CalendarWeekday(label: 'Mi'),
                  _CalendarWeekday(label: 'J'),
                  _CalendarWeekday(label: 'V'),
                  _CalendarWeekday(label: 'S'),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.personalCalendar.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  return _CalendarDayTile(day: viewModel.personalCalendar[index]);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pestaña social con estado vacío y llamada a la acción para agregar amigos.
class _FriendsStreakTab extends StatelessWidget {
  /// Crea la experiencia social vacía.
  const _FriendsStreakTab({required this.viewModel});

  final StreakViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF17212A),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF2B3943), width: 2),
          ),
          child: Column(
            children: [
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFF27A8E0), size: 92),
              ),
              const SizedBox(height: 18),
              const Text(
                '¡Empieza una Racha entre amigos y progresa cada día en compañía!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => const UnderConstructionCommand().execute(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF52BDF7),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF1D7EAE),
                        offset: Offset(0, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF101820), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        viewModel.inviteFriendsLabel,
                        style: const TextStyle(
                          color: Color(0xFF101820),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.friendsEmptyStateText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9AA7B1),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Etiqueta de dia de semana para la cabecera del calendario.
class _CalendarWeekday extends StatelessWidget {
  /// Crea la etiqueta compacta de un dia de la semana.
  const _CalendarWeekday({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF667580),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Celda visual de un dia dentro del calendario de racha.
class _CalendarDayTile extends StatelessWidget {
  /// Crea una celda de calendario a partir del modelo del dia.
  const _CalendarDayTile({required this.day});

  final StreakCalendarDay day;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = day.isToday
        ? const Color(0xFF5B6772)
        : day.isFrozen
            ? const Color(0xFF74D7FF).withValues(alpha: 0.35)
            : day.isStreakDay
                ? const Color(0xFFFFB53D)
                : const Color(0xFF26323A);
    final Color textColor = day.isFrozen || day.isToday || day.isStreakDay ? Colors.black : const Color(0xFF7D8992);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: day.isFrozen ? Border.all(color: const Color(0xFF8CE0FF), width: 2) : null,
      ),
      child: Text(
        '${day.dayNumber}',
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}