import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/command.dart';
import '../../core/service_locator.dart';
import '../../core/under_construction_command.dart';
import '../../models/lesson_node.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../lessons/active_lesson_screen.dart';
import '../shop/shop_screen.dart';
import '../streak/streak_screen.dart';

/// Pantalla principal que muestra el mapa de lecciones del usuario.
class HomeView extends StatefulWidget {
  /// Crea la vista Home.
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel = HomeViewModel();
  late final ScrollController _scrollController = ScrollController();
  late final Command<void> _showCourseDialogCommand =
      _ShowCourseDialogCommand(_showCourseDialog);
  late final Command<void> _showEnergyDialogCommand =
      _ShowEnergyDialogCommand(_showEnergyDialog);
  late final Command<void> _openStreakScreenCommand =
      _OpenStreakScreenCommand(_openStreakScreen);
  late final Command<void> _openShopScreenCommand =
      _OpenShopScreenCommand(_openShopScreen);

  String? _unlockedNodeId;
  bool _pendingScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadLessonNodes();
      _viewModel.loadProfile();
    });

    // Scroll persistente: posicionarse en la última lección completada
    final int savedIndex = ServiceLocator.lastCompletedLessonIndex;
    if (savedIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToNode(savedIndex);
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onNodeTap(LessonNode node, List<LessonNode> allNodes) async {
    if (node.status == NodeStatus.locked) {
      _showLockedLessonMessage(context);
      return;
    }

    final String? completedNodeId = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => ActiveLessonScreen(nodeId: node.id),
      ),
    );

    if (!mounted || completedNodeId == null) return;

    // Guardar el índice completado para scroll persistente
    final int completedIndex =
        _viewModel.lessonNodes.indexWhere((n) => n.id == completedNodeId);
    ServiceLocator.setLastCompletedLessonIndex(completedIndex);

    // Recargar mapa con la progresión actualizada
    await _viewModel.loadLessonNodes();
    await _viewModel.loadProfile();

    if (!mounted) return;

    // Determinar el índice del siguiente nodo (X+1)
    final int nextIndex = completedIndex + 1;

    if (nextIndex < _viewModel.lessonNodes.length) {
      final String nextNodeId = _viewModel.lessonNodes[nextIndex].id;
      setState(() {
        _unlockedNodeId = nextNodeId;
        _pendingScroll = true;
      });

      // Esperar a que el layout se pinte y luego hacer scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToNode(nextIndex);
      });
    }
  }

  void _scrollToNode(int nodeIndex) {
    if (!_scrollController.hasClients) return;

    // Calcular la posición Y aproximada del nodo
    const double topPadding = 12;
    const double normalSize = 88;
    const double verticalGap = 132;
    const double bossSize = 118;

    double yPos = 0;
    for (var i = 0; i <= nodeIndex; i++) {
      final bool isBoss = i < _viewModel.lessonNodes.length &&
          _viewModel.lessonNodes[i].type == LessonNodeType.boss;
      final double size = isBoss ? bossSize : normalSize;
      if (i == 0) {
        yPos = topPadding;
      } else {
        yPos += isBoss ? verticalGap + 18 : verticalGap;
      }
    }
    // Centrar en pantalla
    final double viewportHeight = _scrollController.position.viewportDimension;
    final double targetScroll = yPos - viewportHeight / 3;

    _scrollController.animateTo(
      math.max(0, targetScroll),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );

    // Limpiar unlock después de la animación
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _unlockedNodeId = null;
        _pendingScroll = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
            controller: _scrollController,
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
                  _LearningPath(
                    lessonNodes: _viewModel.lessonNodes,
                    unlockedNodeId: _unlockedNodeId,
                    onNodeTap: (node) =>
                        _onNodeTap(node, _viewModel.lessonNodes),
                  ),
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

/// Comandos
class _ShowCourseDialogCommand implements Command<void> {
  const _ShowCourseDialogCommand(this._action);
  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) => _action();
}

class _ShowEnergyDialogCommand implements Command<void> {
  const _ShowEnergyDialogCommand(this._action);
  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) => _action();
}

class _OpenStreakScreenCommand implements Command<void> {
  const _OpenStreakScreenCommand(this._action);
  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) => _action();
}

class _OpenShopScreenCommand implements Command<void> {
  const _OpenShopScreenCommand(this._action);
  final VoidCallback _action;

  @override
  void execute([BuildContext? context]) => _action();
}

/// Barra superior con los indicadores de progreso del usuario.
class _TopStatsBar extends StatelessWidget {
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

class _TopStatItem extends StatelessWidget {
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

    if (onTap == null) return row;

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

class _CourseModalCard extends StatelessWidget {
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

class _EnergyModalCard extends StatelessWidget {
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

class _StageBanner extends StatelessWidget {
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
  const _LearningPath({
    required this.lessonNodes,
    this.unlockedNodeId,
    this.onNodeTap,
  });

  final List<LessonNode> lessonNodes;
  final String? unlockedNodeId;
  final ValueChanged<LessonNode>? onNodeTap;

  @override
  Widget build(BuildContext context) {
    if (lessonNodes.isEmpty) {
      return const SizedBox(height: 420);
    }

    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final _PathLayout layout = _PathLayout.build(
            lessonNodes: lessonNodes,
            width: constraints.maxWidth,
          );

          return SizedBox(
            width: constraints.maxWidth,
            height: layout.totalHeight,
            child: Stack(
              children: [
                for (final item in layout.items)
                  _PathLesson(
                    node: item.node,
                    left: item.left,
                    top: item.top,
                    size: item.size,
                    isNewlyUnlocked: item.node.id == unlockedNodeId,
                    isActive: item.node.status == NodeStatus.active,
                    onTap: () => onNodeTap?.call(item.node),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Nodo posicionado que traduce un [LessonNode] en una pieza visual del mapa.
class _PathLesson extends StatefulWidget {
  const _PathLesson({
    required this.node,
    required this.left,
    required this.top,
    required this.size,
    this.isNewlyUnlocked = false,
    this.isActive = false,
    this.onTap,
  });

  final LessonNode node;
  final double left;
  final double top;
  final double size;
  final bool isNewlyUnlocked;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<_PathLesson> createState() => _PathLessonState();
}

class _PathLessonState extends State<_PathLesson>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  );

  late final AnimationController _unlockController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
    if (widget.isNewlyUnlocked) {
      _playUnlockAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant _PathLesson oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }

    // Detectar desbloqueo
    if (widget.isNewlyUnlocked && !oldWidget.isNewlyUnlocked) {
      _playUnlockAnimation();
    }
  }

  void _playUnlockAnimation() {
    _unlockController.forward(from: 0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (widget.node.type) {
      LessonNodeType.boss => _CharacterNode(
          size: widget.size,
          status: widget.node.status,
        ),
      _ => _LessonNode(
          size: widget.size,
          node: widget.node,
          isNewlyUnlocked: widget.isNewlyUnlocked,
        ),
    };

    final bool isLocked = widget.node.status == NodeStatus.locked;

    return Positioned(
      top: widget.top,
      left: widget.left,
      child: Semantics(
        label: widget.node.title,
        button: !isLocked,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _unlockController]),
            builder: (context, child) {
              final double unlockScale = widget.isNewlyUnlocked
                  ? 1 +
                      (_unlockController.value *
                          math.sin(_unlockController.value * math.pi * 4) *
                          0.08)
                  : 0;

              final double pulseScale = widget.isActive
                  ? 1 +
                      (math.sin(_pulseController.value * math.pi * 2) * 0.04)
                  : 0;

              final double totalScale =
                  1 + unlockScale + (widget.isActive ? pulseScale - 1 : 0);

              return Transform.scale(
                scale: math.max(1, totalScale),
                child: child,
              );
            },
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PathLayout {
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

class _PathItemPlacement {
  const _PathItemPlacement({required this.node, required this.left, required this.top, required this.size});

  final LessonNode node;
  final double left;
  final double top;
  final double size;
}

class _PathLinePainter extends CustomPainter {
  const _PathLinePainter({required this.nodes, required this.centers});

  final List<LessonNode> nodes;
  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    return; // TODO: Fix Web Canvas Bezier bug later
  }

  @override
  bool shouldRepaint(covariant _PathLinePainter oldDelegate) => oldDelegate.centers != centers;
}

/// Nodo circular reutilizable para representar una leccion del mapa.
class _LessonNode extends StatefulWidget {
  const _LessonNode({
    required this.size,
    required this.node,
    this.isNewlyUnlocked = false,
  });

  final double size;
  final LessonNode node;
  final bool isNewlyUnlocked;

  @override
  State<_LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<_LessonNode>
    with SingleTickerProviderStateMixin {
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
    if (widget.isNewlyUnlocked) return const Color(0xFF6D5CFF);
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
        final double pulseScale =
            isActive ? 1 + (math.sin(_pulseController.value * math.pi * 2) * 0.04) : 1;

        return Transform.scale(
          scale: pulseScale,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _backgroundColor(),
          shape: BoxShape.circle,
          boxShadow: widget.node.status == NodeStatus.locked && !widget.isNewlyUnlocked
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

class _CharacterNode extends StatelessWidget {
  const _CharacterNode({required this.size, required this.status});

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
    final Color bodyColor =
        isCompleted ? _completedColor : isActive ? _activeColor : _lockedColor;
    final Color faceColor =
        isCompleted || isActive ? Colors.white : _lockedIconColor;
    final List<BoxShadow> shadows = status == NodeStatus.locked
        ? const <BoxShadow>[]
        : [
            BoxShadow(
              color: (isCompleted ? const Color(0xFF14914C) : const Color(0xFF4636B5))
                  .withValues(alpha: 0.88),
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
