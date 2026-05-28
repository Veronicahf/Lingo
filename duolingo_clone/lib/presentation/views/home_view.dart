import 'dart:math' as math;

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
                  _StageBanner(
                    sectionTitle: _viewModel.currentSectionTitle,
                    stageTitle: _viewModel.currentStageTitle,
                  ),
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
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: 1,
              heightFactor: 1,
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
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              widthFactor: 1,
              heightFactor: 1,
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
  const _StageBanner({required this.sectionTitle, required this.stageTitle});

  final String sectionTitle;
  final String stageTitle;

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
                  children: [
                    Text(
                      sectionTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stageTitle,
                      style: const TextStyle(
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
    if (lessonNodes.isEmpty) {
      return const SizedBox(height: 420);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final _PathLayout layout = _PathLayout.build(
          lessonNodes: lessonNodes,
          width: constraints.maxWidth,
        );

        return SizedBox(
          height: layout.totalHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PathLinePainter(nodes: lessonNodes, centers: layout.centers),
                ),
              ),
              for (final item in layout.items)
                _PathLesson(
                  node: item.node,
                  left: item.left,
                  top: item.top,
                  size: item.size,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Nodo posicionado que traduce un [LessonNode] en una pieza visual del mapa.
class _PathLesson extends StatelessWidget {
  /// Crea un nodo visual a partir de su modelo de dominio.
  const _PathLesson({
    required this.node,
    required this.left,
    required this.top,
    required this.size,
  });

  final LessonNode node;
  final double left;
  final double top;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (node.type) {
      LessonNodeType.boss => _CharacterNode(
          size: size,
          status: node.status,
        ),
      _ => _LessonNode(
          size: size,
          node: node,
        ),
    };

    final bool isLocked = node.status == NodeStatus.locked;

    return Positioned(
      top: top,
      left: left,
      child: Semantics(
        label: node.title,
        button: !isLocked,
        child: GestureDetector(
          onTap: () {
            if (isLocked) {
              _showLockedLessonMessage(context);
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ActiveLessonScreen(),
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }
}

/// Distribución calculada para pintar un mapa en zig-zag.
class _PathLayout {
  /// Crea un layout de recorrido con posición y centros para la línea de conexión.
  const _PathLayout({required this.items, required this.centers, required this.totalHeight});

  final List<_PathItemPlacement> items;
  final List<Offset> centers;
  final double totalHeight;

  static _PathLayout build({required List<LessonNode> lessonNodes, required double width}) {
    const double horizontalMargin = 22;
    const double topPadding = 12;
    const double verticalGap = 132;
    const double bossSize = 118;
    const double normalSize = 88;

    final List<_PathItemPlacement> items = <_PathItemPlacement>[];
    final List<Offset> centers = <Offset>[];

    double currentCenterY = topPadding + normalSize / 2;

    for (var index = 0; index < lessonNodes.length; index++) {
      final LessonNode node = lessonNodes[index];
      final bool isBoss = node.type == LessonNodeType.boss;
      final double size = isBoss ? bossSize : normalSize;
      final double left = isBoss
          ? (width - size) / 2
          : index.isEven
              ? horizontalMargin
              : width - size - horizontalMargin;
      final double top = currentCenterY - size / 2;

      items.add(_PathItemPlacement(node: node, left: left, top: top, size: size));
      centers.add(Offset(left + size / 2, top + size / 2));

      currentCenterY += isBoss ? verticalGap + 18 : verticalGap;
    }

    final double totalHeight = items.isEmpty ? 420 : items.last.top + items.last.size + 40;
    return _PathLayout(items: items, centers: centers, totalHeight: totalHeight);
  }
}

/// Posición calculada para un nodo individual del recorrido.
class _PathItemPlacement {
  /// Crea una ubicación para un nodo.
  const _PathItemPlacement({required this.node, required this.left, required this.top, required this.size});

  final LessonNode node;
  final double left;
  final double top;
  final double size;
}

/// Pintor de la línea de conexión entre LessonNode.
class _PathLinePainter extends CustomPainter {
  /// Crea un pintor con la secuencia de centros a conectar.
  const _PathLinePainter({required this.nodes, required this.centers});

  final List<LessonNode> nodes;
  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2 || nodes.length < 2) {
      return;
    }

    for (var index = 1; index < centers.length; index++) {
      final Offset previous = centers[index - 1];
      final Offset current = centers[index];
      final NodeStatus previousStatus = nodes[index - 1].status;
      final NodeStatus currentStatus = nodes[index].status;
      final double midY = (previous.dy + current.dy) / 2;

      final Color segmentColor;
      if (currentStatus == NodeStatus.locked) {
        segmentColor = const Color(0xFF66737C);
      } else if (previousStatus == NodeStatus.completed && currentStatus == NodeStatus.completed) {
        segmentColor = const Color(0xFF9EEB2A);
      } else if (previousStatus == NodeStatus.active || currentStatus == NodeStatus.active) {
        segmentColor = const Color(0xFF6D5CFF);
      } else {
        segmentColor = const Color(0xFF49D8FF);
      }

      final Path segmentPath = Path()..moveTo(previous.dx, previous.dy);
      segmentPath
        ..quadraticBezierTo(previous.dx, midY, (previous.dx + current.dx) / 2, midY)
        ..quadraticBezierTo(current.dx, midY, current.dx, current.dy);

      final Paint paint = Paint()
        ..color = segmentColor
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(segmentPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathLinePainter oldDelegate) => oldDelegate.centers != centers;
}

/// Nodo circular reutilizable para representar una leccion del mapa.
class _LessonNode extends StatefulWidget {
  /// Crea el render visual de una leccion basada en su tipo y estado.
  const _LessonNode({required this.size, required this.node});

  final double size;
  final LessonNode node;

  @override
  State<_LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<_LessonNode> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  );

  @override
  void initState() {
    super.initState();
    if (widget.node.status == NodeStatus.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _LessonNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool isActive = widget.node.status == NodeStatus.active;
    if (isActive && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isActive && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _iconForNode() {
    return switch (widget.node.status) {
      NodeStatus.completed => widget.node.type == LessonNodeType.boss
          ? Icons.workspace_premium_rounded
          : Icons.star_rounded,
      NodeStatus.active => switch (widget.node.type) {
          LessonNodeType.star => Icons.star_rounded,
          LessonNodeType.book => Icons.menu_book_rounded,
          LessonNodeType.dumbbell => Icons.fitness_center_rounded,
          LessonNodeType.boss => Icons.workspace_premium_rounded,
        },
      NodeStatus.locked => switch (widget.node.type) {
          LessonNodeType.star => Icons.star_outline_rounded,
          LessonNodeType.book => Icons.menu_book_outlined,
          LessonNodeType.dumbbell => Icons.fitness_center_outlined,
          LessonNodeType.boss => Icons.lock_rounded,
        },
    };
  }

  Color _backgroundColor() {
    return switch (widget.node.status) {
      NodeStatus.completed => const Color(0xFF30D158),
      NodeStatus.active => const Color(0xFF6D5CFF),
      NodeStatus.locked => const Color(0xFF5C6670),
    };
  }

  Color _shadowColor() {
    return switch (widget.node.status) {
      NodeStatus.completed => const Color(0xFF14914C),
      NodeStatus.active => const Color(0xFF4636B5),
      NodeStatus.locked => Colors.transparent,
    };
  }

  Color _iconColor() {
    return switch (widget.node.status) {
      NodeStatus.completed => Colors.white,
      NodeStatus.active => Colors.white,
      NodeStatus.locked => const Color(0xFF2C363D),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.node.status == NodeStatus.active;
    final bool isCompleted = widget.node.status == NodeStatus.completed;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double pulseScale = isActive ? 1 + (math.sin(_pulseController.value * math.pi * 2) * 0.04) : 1;

        return Transform.scale(
          scale: pulseScale,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _backgroundColor(),
          shape: BoxShape.circle,
          boxShadow: widget.node.status == NodeStatus.locked
              ? const <BoxShadow>[]
              : [
                  BoxShadow(
                    color: _shadowColor().withValues(alpha: isCompleted ? 0.9 : 0.85),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
          ),
          child: Icon(
            _iconForNode(),
            color: _iconColor(),
            size: isActive
                ? widget.size * 0.5
                : isCompleted
                    ? widget.size * 0.44
                    : widget.size * 0.4,
          ),
        ),
      ),
    );
  }
}

/// Nodo tipo boss o personaje que representa un hito especial del mapa.
class _CharacterNode extends StatelessWidget {
  /// Crea la version ilustrada del boss del mapa.
  const _CharacterNode({
    required this.size,
    required this.status,
  });

  final double size;
  final NodeStatus status;

  static const Color _completedColor = Color(0xFF30D158);
  static const Color _activeColor = Color(0xFF6D5CFF);
  static const Color _lockedColor = Color(0xFF5C6670);
  static const Color _lockedIconColor = Color(0xFF2C363D);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == NodeStatus.completed;
    final bool isActive = status == NodeStatus.active;
    final Color bodyColor = isCompleted
        ? _completedColor
        : isActive
            ? _activeColor
            : _lockedColor;
    final Color faceColor = isCompleted || isActive ? Colors.white : _lockedIconColor;
    final List<BoxShadow> shadows = status == NodeStatus.locked
        ? const <BoxShadow>[]
        : [
            BoxShadow(
              color: (isCompleted ? const Color(0xFF14914C) : const Color(0xFF4636B5)).withValues(alpha: 0.88),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ];

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
              boxShadow: shadows,
            ),
          ),
          Positioned(
            top: size * 0.22,
            child: Icon(
              isCompleted ? Icons.workspace_premium_rounded : Icons.person_rounded,
              color: faceColor.withValues(alpha: 0.8),
              size: size * 0.36,
            ),
          ),
          Positioned(
            bottom: size * 0.12,
            child: Icon(
              isCompleted ? Icons.star_rounded : Icons.stars_rounded,
              color: faceColor.withValues(alpha: 0.58),
              size: size * 0.26,
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra una respuesta breve cuando el usuario toca una leccion bloqueada.
void _showLockedLessonMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      const SnackBar(
        content: Text(
          'Debes completar las lecciones anteriores',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Color(0xFF2B3138),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
}
