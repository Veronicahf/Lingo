import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/command.dart';
import '../../core/service_locator.dart';
import '../../models/dtos/lesson_dto.dart';
import '../../viewmodels/lesson_viewmodel.dart';
import '../registration/registration_screen.dart';
import '../widgets/mascot_animation_widget.dart';
import 'feedback_sheet.dart';
import 'lesson_complete_screen.dart';
import 'lesson_factory.dart';

/// Pantalla contenedora de una leccion activa dentro del motor de actividades.
class ActiveLessonScreen extends StatefulWidget {
  /// Crea la pantalla de leccion activa.
  ///
  /// [nodeId] es el identificador del [LessonNode] del mapa a jugar.
  /// Si es null, se asume que el [viewModel] ya fue precargado (ej: práctica).
  const ActiveLessonScreen({super.key, this.nodeId, this.viewModel});

  /// ID del nodo del mapa cuyas actividades se cargarán.
  /// Puede ser null cuando se usa en modo práctica con un ViewModel inyectado.
  final String? nodeId;

  /// ViewModel opcional para inyectar desde otra pantalla.
  final LessonViewModel? viewModel;

  @override
  State<ActiveLessonScreen> createState() => _ActiveLessonScreenState();
}

class _ActiveLessonScreenState extends State<ActiveLessonScreen> {
  late final LessonViewModel _viewModel;
  late final Command<void> _skipRepeatCommand;
  String _currentAnswer = '';
  String? _lastActivityId;
  bool _didNavigateToCompletion = false;

  static const Color _backgroundColor = Color(0xFF101820);
  static const Color _progressColor = Color(0xFF9EEB2A);
  static const Color _progressTrack = Color(0xFF2B3840);
  static const Color _buttonColor = Color(0xFF8CE317);
  static const Color _buttonShadow = Color(0xFF5FA10F);

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? LessonViewModel();
    _skipRepeatCommand = _SkipRepeatCommand(_viewModel);

    if (widget.viewModel == null && widget.nodeId != null) {
      _viewModel.loadLesson(widget.nodeId!);
    }

    _viewModel.addListener(_syncCurrentAnswerWithActivity);
    _viewModel.addListener(_onLessonComplete);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncCurrentAnswerWithActivity);
    _viewModel.removeListener(_onLessonComplete);

    if (widget.viewModel == null) {
      _viewModel.dispose();
    }

    super.dispose();
  }

  void _syncCurrentAnswerWithActivity() {
    final activity = _viewModel.currentActivityOrNull;
    if (activity == null) {
      return;
    }

    if (_lastActivityId == activity.id) {
      return;
    }

    _lastActivityId = activity.id;
    if (!mounted) {
      return;
    }

    setState(() {
      _currentAnswer = '';
    });
  }

  Future<void> _onLessonComplete() async {
    if (_viewModel.isSuccess && mounted && !_didNavigateToCompletion) {
      _didNavigateToCompletion = true;

      // En modo práctica, no hay nodo del mapa, solo volvemos atrás
      if (widget.nodeId == null) {
        Navigator.pop(context);
        return;
      }

      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => LessonCompleteScreen(
            xpGained: 10,
            completedNodeId: widget.nodeId!,
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, widget.nodeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LessonViewModel viewModel = _viewModel;
    final lessonActivity = viewModel.currentActivityOrNull;

    if (viewModel.activities.isEmpty || lessonActivity == null) {
      final bool isError = viewModel.state == LessonState.error;
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MascotAnimationWidget.fromEmotion(
                  emotion: isError ? 'sad' : 'loading',
                  width: 220,
                  height: 220,
                ),
                const SizedBox(height: 16),
                Text(
                  isError
                      ? 'No se pudieron cargar las actividades'
                      : 'Preparando tu lección...',
                  style: const TextStyle(
                    color: Color(0xFF9AA7B1),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: widget.nodeId != null
                          ? () => viewModel.loadLesson(widget.nodeId!)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF55C7FF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'REINTENTAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider<LessonViewModel>.value(
      value: viewModel,
      child: Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.close_rounded, color: Color(0xFF9AA7B1), size: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Consumer<LessonViewModel>(
                          builder: (context, vm, _) {
                            final double targetProgress = vm.progress.clamp(0.0, 1.0);

                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: targetProgress),
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                              builder: (context, animatedProgress, _) {
                                return Container(
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _progressTrack,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: animatedProgress,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _progressColor,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          lessonActivity.prompt,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: Colors.transparent,
                            child: LessonFactory.buildActivity(
                              LessonDTO.fromActivity(lessonActivity),
                              (answer) {
                                setState(() {
                                  _currentAnswer = answer;
                                });
                                _viewModel.setSelectedAnswer(answer);
                              },
                              onRepeatSkip: _skipRepeatCommand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: GestureDetector(
                onTap: _currentAnswer.isEmpty
                    ? null
                    : () async {
                        await _viewModel.checkAnswer(_currentAnswer);

                        if (!mounted) {
                          return;
                        }

                        await showFeedbackSheet(
                          context,
                          isCorrect: _viewModel.isCorrect,
                          correctAnswer: lessonActivity.correctAnswer,
                          aiExplanation: lessonActivity.aiExplanation,
                          isGameOver: _viewModel.isGameOver,
                          onContinue: _viewModel.isCorrect
                              ? () {
                                  _viewModel.nextActivity();
                                }
                              : null,
                        );

                        if (!mounted) return;
                        if (ServiceLocator.registrationRequired &&
                            _viewModel.lessonsCompleted >= 2) {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const RegistrationScreen(),
                            ),
                          );
                        }
                      },
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: _currentAnswer.isEmpty ? const Color(0xFF6E7780) : _buttonColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (_currentAnswer.isEmpty ? const Color(0xFF4A5258) : _buttonShadow).withOpacity(0.85),
                        offset: const Offset(0, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'COMPROBAR',
                    style: TextStyle(
                      color: _currentAnswer.isEmpty ? const Color(0xFF8A9197) : const Color(0xFF09220A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}

/// Comando que marca la actividad actual como saltada dentro de la leccion.
class _SkipRepeatCommand implements Command<void> {
  const _SkipRepeatCommand(this._viewModel);

  final LessonViewModel _viewModel;

  @override
  void execute([BuildContext? context]) {
    _viewModel.skipCurrentActivity();
  }
}
