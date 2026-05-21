import 'package:flutter/material.dart';

import '../../models/lesson_node.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../lessons/active_lesson_screen.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadLessonNodes();
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
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const _TopStatsBar(),
              const SizedBox(height: 14),
              const _StageBanner(),
              const SizedBox(height: 18),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  return _LearningPath(lessonNodes: _viewModel.lessonNodes);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra superior con los indicadores de progreso del usuario.
class _TopStatsBar extends StatelessWidget {
  /// Crea la barra superior con valores decorativos del progreso.
  const _TopStatsBar();

  static const Color _flagColor = Color(0xFFFFFFFF);
  static const Color _fireColor = Color(0xFFFFB42B);
  static const Color _gemColor = Color(0xFF48B9FF);
  static const Color _heartColor = Color(0xFFF88CD4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: const [
          Expanded(
            child: _TopStatItem(
              icon: Icons.flag_rounded,
              iconColor: _flagColor,
              label: '13',
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.local_fire_department_rounded,
              iconColor: _fireColor,
              label: '1',
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.diamond_rounded,
              iconColor: _gemColor,
              label: '931',
            ),
          ),
          Expanded(
            child: _TopStatItem(
              icon: Icons.favorite_rounded,
              iconColor: _heartColor,
              label: '∞',
              useInfinityLabel: true,
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
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool useInfinityLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
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
