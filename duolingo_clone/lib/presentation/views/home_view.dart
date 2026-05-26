import 'package:flutter/material.dart';

import '../../core/command.dart';
import '../../core/under_construction_command.dart';
import '../../models/lesson_node.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../lessons/active_lesson_screen.dart';
import '../shop/shop_screen.dart';
import '../streak/streak_screen.dart';

/// Pantalla principal que muestra el mapa de lecciones del usuario.
///
/// Esta vista conecta con [HomeViewModel], escucha sus cambios y renderiza el recorrido desde
/// una lista de [LessonNode] para evitar datos y posiciones hardcodeadas.
class HomeView extends StatefulWidget {
  /// Crea la vista Home.
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// Estado interno de [HomeView] que carga el mapa de lecciones y libera la ViewModel.
class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel = HomeViewModel();
  late final Command<void> _showCourseDialogCommand = _ShowCourseDialogCommand(_showCourseDialog);
  late final Command<void> _showEnergyDialogCommand = _ShowEnergyDialogCommand(_showEnergyDialog);
  late final Command<void> _openStreakScreenCommand = _OpenStreakScreenCommand(_openStreakScreen);
  late final Command<void> _openShopScreenCommand = _OpenShopScreenCommand(_openShopScreen);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadLessonNodes();
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
        return Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  _TopStatsBar(
                    courseScoreLabel: _viewModel.currentCourseScore,
                    energyLabel: _viewModel.heartsValueText,
                    streakLabel: _viewModel.streakDaysText,
                    gemsLabel: _viewModel.gemsText,
                    onCourseTap: _showCourseDialogCommand.execute,
                    onStreakTap: _openStreakScreenCommand.execute,
                    onGemTap: _openShopScreenCommand.execute,
                    onEnergyTap: _showEnergyDialogCommand.execute,
                  ),
                  const SizedBox(height: 14),
                  const _StageBanner(),
                  const SizedBox(height: 18),
                  _LearningPath(lessonNodes: _viewModel.lessonNodes),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCourseDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 14, top: 68),
                child: _CourseModalCard(viewModel: _viewModel),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEnergyDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 14, top: 68),
                child: _EnergyModalCard(viewModel: _viewModel),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openStreakScreen() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const StreakScreen()),
    );
  }

  void _openShopScreen() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const ShopScreen()),
    );
  }
}

/// Comando que encapsula la apertura del modal de cursos.
class _ShowCourseDialogCommand implements Command<void> {
  /// Crea el comando enlazado a la acción visual correspondiente.
  const _ShowCourseDialogCommand(this._action);

  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) {
    _action();
  }
}

/// Comando que encapsula la apertura del modal de energía.
class _ShowEnergyDialogCommand implements Command<void> {
  /// Crea el comando enlazado a la acción visual correspondiente.
  const _ShowEnergyDialogCommand(this._action);

  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) {
    _action();
  }
}

/// Comando que encapsula la navegación hacia la pantalla de racha.
class _OpenStreakScreenCommand implements Command<void> {
  /// Crea el comando enlazado a la navegación.
  const _OpenStreakScreenCommand(this._action);

  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) {
    _action();
  }
}

/// Comando que encapsula la navegación hacia la tienda.
class _OpenShopScreenCommand implements Command<void> {
  /// Crea el comando enlazado a la navegación.
  const _OpenShopScreenCommand(this._action);

  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) {
    _action();
  }
}

/// Barra superior con los indicadores de progreso del usuario.
class _TopStatsBar extends StatelessWidget {
  /// Crea la barra superior con valores decorativos del progreso.
  const _TopStatsBar({
    required this.courseScoreLabel,
    required this.energyLabel,
    required this.streakLabel,
    required this.gemsLabel,
    required this.onCourseTap,
    required this.onStreakTap,
    required this.onGemTap,
    required this.onEnergyTap,
  });

  final String courseScoreLabel;
  final String energyLabel;
  final String streakLabel;
  final String gemsLabel;
  final VoidCallback onCourseTap;
  final VoidCallback onStreakTap;
  final VoidCallback onGemTap;
  final VoidCallback onEnergyTap;

  static const Color _flagColor = Color(0xFFFFFFFF);
  static const Color _fireColor = Color(0xFFFFB42B);
  static const Color _gemColor = Color(0xFF48B9FF);
  static const Color _heartColor = Color(0xFFF88CD4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: _TopStatItem(
              icon: Icons.flag_rounded,
              iconColor: _flagColor,
              label: courseScoreLabel,
              onTap: onCourseTap,
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.local_fire_department_rounded,
              iconColor: _fireColor,
              label: streakLabel,
              onTap: onStreakTap,
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.diamond_rounded,
              iconColor: _gemColor,
              label: gemsLabel,
              onTap: onGemTap,
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.favorite_rounded,
              iconColor: _heartColor,
              label: energyLabel,
              useInfinityLabel: true,
              onTap: onEnergyTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Elemento visual simple usado dentro de la barra superior de progreso.
class _TopStatItem extends StatelessWidget {
  /// Crea un indicador compacto con icono y valor.
  const _TopStatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.useInfinityLabel = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool useInfinityLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 25),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: iconColor,
            fontSize: useInfinityLabel ? 22 : 17,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return row;
    }

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: row,
      ),
    );
  }
}

/// Tarjeta flotante que muestra la información del curso actual.
class _CourseModalCard extends StatelessWidget {
  /// Crea la tarjeta del modal de cursos a partir del ViewModel del Home.
  const _CourseModalCard({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17212A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF2B3943), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF24313A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFFFFFFFF),
                  size: 44,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.currentCourseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewModel.currentCourseScore,
                      style: const TextStyle(
                        color: Color(0xFF9AA7B1),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => const UnderConstructionCommand().execute(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF121A21),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF3A4650), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Color(0xFF9AA7B1), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    viewModel.coursesButtonLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta flotante que muestra el estado de energía ilimitada.
class _EnergyModalCard extends StatelessWidget {
  /// Crea la tarjeta del modal de energía a partir del ViewModel del Home.
  const _EnergyModalCard({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17212A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF2B3943), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: const Color(0xFF202A34),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFF88CD4),
              size: 68,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.energyDialogTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.energyDialogSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9AA7B1),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => const UnderConstructionCommand().execute(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF55C7FF),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF55C7FF).withValues(alpha: 0.18),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                viewModel.energyButtonLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF101820),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner de etapa que contextualiza el tema actual del mapa.
class _StageBanner extends StatelessWidget {
  /// Crea el banner de etapa superior.
  const _StageBanner();

  static const Color _cardColor = Color(0xFFCE78F8);
  static const Color _shadowColor = Color(0xFF8F4CB4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: _shadowColor,
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ETAPA 2, SECCIÓN 7',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Habla de comidas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 68,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                border: Border(
                  left: BorderSide(color: Colors.black.withValues(alpha: 0.10), width: 2),
                ),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ruta visual construida a partir de datos estructurados del mapa.
class _LearningPath extends StatelessWidget {
  /// Crea la ruta a partir de la lista de nodos recibida desde el ViewModel.
  const _LearningPath({required this.lessonNodes});

  final List<LessonNode> lessonNodes;

  @override
  Widget build(BuildContext context) {
    final double pathHeight = _computePathHeight(lessonNodes);

    return SizedBox(
      height: pathHeight,
      child: Stack(
        children: lessonNodes.map((lessonNode) => _PathLesson(node: lessonNode)).toList(),
      ),
    );
  }

  double _computePathHeight(List<LessonNode> nodes) {
    if (nodes.isEmpty) {
      return 420;
    }

    final double maxY = nodes
        .map((lessonNode) => lessonNode.position.dy)
        .reduce((current, next) => current > next ? current : next);
    return maxY + 220;
  }
}

/// Nodo posicionado que traduce un [LessonNode] en una pieza visual del mapa.
class _PathLesson extends StatelessWidget {
  /// Crea un nodo visual a partir de su modelo de dominio.
  const _PathLesson({required this.node});

  final LessonNode node;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (node.type) {
      LessonNodeType.boss => _CharacterNode(
          size: 118,
          active: node.status != LessonNodeStatus.locked,
        ),
      _ => _LessonNode(
          size: 88,
          node: node,
        ),
    };

    final bool isActive = node.status == LessonNodeStatus.active;

    return Positioned(
      top: node.position.dy,
      left: node.position.dx,
      child: Semantics(
        label: node.title,
        button: isActive,
        child: isActive
            ? GestureDetector(
                // TODO: Extraer a un Command (ej. StartLessonCommand) cuando se implemente HomeViewModel.
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ActiveLessonScreen(),
                    ),
                  );
                },
                child: child,
              )
            : child,
      ),
    );
  }
}

/// Nodo circular reutilizable para representar una leccion del mapa.
class _LessonNode extends StatelessWidget {
  /// Crea el render visual de una leccion basada en su tipo y estado.
  const _LessonNode({required this.size, required this.node});

  final double size;
  final LessonNode node;

  static const Color _activeColor = Color(0xFFC775F4);
  static const Color _activeShadow = Color(0xFF7A4AA8);
  static const Color _lockedColor = Color(0xFF495560);
  static const Color _lockedIconColor = Color(0xFF74818B);

  IconData get _icon {
    return switch (node.type) {
      LessonNodeType.star => Icons.star_rounded,
      LessonNodeType.book => Icons.menu_book_rounded,
      LessonNodeType.dumbbell => Icons.fitness_center_rounded,
      LessonNodeType.boss => Icons.lock_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = node.status == LessonNodeStatus.active;
    final bool isCompleted = node.status == LessonNodeStatus.completed;
    final Color backgroundColor = isActive || isCompleted ? _activeColor : _lockedColor;
    final Color iconColor = isActive || isCompleted ? Colors.white : _lockedIconColor;
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: isActive || isCompleted ? _activeShadow : Colors.black.withValues(alpha: 0.14),
        offset: const Offset(0, 8),
        blurRadius: 0,
      ),
    ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: shadows,
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive || isCompleted
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
        ),
        child: Icon(_icon, color: iconColor, size: size * 0.42),
      ),
    );
  }
}

/// Nodo tipo boss o personaje que representa un hito especial del mapa.
class _CharacterNode extends StatelessWidget {
  /// Crea la version ilustrada del boss del mapa.
  const _CharacterNode({
    required this.size,
    required this.active,
  });

  final double size;
  final bool active;

  static const Color _activeColor = Color(0xFFC775F4);
  static const Color _lockedColor = Color(0xFF495560);
  static const Color _lockedIconColor = Color(0xFF74818B);

  @override
  Widget build(BuildContext context) {
    final Color bodyColor = active ? _activeColor : _lockedColor;
    final Color faceColor = active ? Colors.white : _lockedIconColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              color: bodyColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  offset: const Offset(0, 8),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          Positioned(
            top: size * 0.22,
            child: Icon(Icons.person_rounded, color: faceColor.withValues(alpha: 0.78), size: size * 0.36),
          ),
          Positioned(
            bottom: size * 0.12,
            child: Icon(Icons.stars_rounded, color: faceColor.withValues(alpha: 0.55), size: size * 0.26),
          ),
        ],
      ),
    );
  }
}
