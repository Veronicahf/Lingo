import 'package:flutter/material.dart';

import '../../core/command.dart';
import '../../viewmodels/lesson_viewmodel.dart';
import 'feedback_sheet.dart';
import 'lesson_factory.dart';

/// Pantalla contenedora de una leccion activa dentro del motor de actividades.
///
/// Esta vista actua como el cascaron visual de la leccion y delega el contenido jugable a
/// [LessonFactory], mientras escucha al [LessonViewModel] para pintar progreso y validar respuestas.
class ActiveLessonScreen extends StatefulWidget {
  /// Crea la pantalla de leccion activa.
  const ActiveLessonScreen({super.key});

  @override
  State<ActiveLessonScreen> createState() => _ActiveLessonScreenState();
}

/// Estado interno de [ActiveLessonScreen] que mantiene vivo el ViewModel de leccion.
class _ActiveLessonScreenState extends State<ActiveLessonScreen> {
  late final LessonViewModel _viewModel = LessonViewModel();
  late final Command<void> _skipRepeatCommand = _SkipRepeatCommand(_viewModel);
  String _currentAnswer = '';
  String? _lastActivityId;

  static const Color _backgroundColor = Color(0xFF101820);
  static const Color _progressColor = Color(0xFF9EEB2A);
  static const Color _progressTrack = Color(0xFF2B3840);
  static const Color _buttonColor = Color(0xFF8CE317);
  static const Color _buttonShadow = Color(0xFF5FA10F);

  @override
  void initState() {
    super.initState();
    _viewModel.loadLesson();
    _viewModel.addListener(_syncCurrentAnswerWithActivity);
    _viewModel.addListener(_onLessonComplete);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncCurrentAnswerWithActivity);
    _viewModel.removeListener(_onLessonComplete);
    _viewModel.dispose();
    super.dispose();
  }

  void _syncCurrentAnswerWithActivity() {
    final String activityId = _viewModel.currentActivity.id;
    if (_lastActivityId == activityId) {
      return;
    }

    _lastActivityId = activityId;
    if (!mounted) {
      return;
    }

    setState(() {
      _currentAnswer = '';
    });
  }

  void _onLessonComplete() {
    if (_viewModel.isSuccess && mounted) {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
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
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: _progressTrack,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: LayoutBuilder(builder: (context, _) {
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _viewModel.progress.clamp(0.0, 1.0),
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
                            );
                          }),
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
                          _viewModel.currentActivity.prompt,
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
                              _viewModel.currentActivity,
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
                          correctAnswer: _viewModel.currentActivity.correctAnswer,
                          aiExplanation: _viewModel.currentActivity.aiExplanation,
                          onContinue: _viewModel.isCorrect
                              ? () {
                                  _viewModel.nextActivity();
                                }
                              : null,
                        );
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
        );
      },
    );
  }
}


/// Comando que marca la actividad actual como saltada dentro de la leccion.
class _SkipRepeatCommand implements Command<void> {
  /// Crea el comando asociado al ViewModel de la leccion.
  const _SkipRepeatCommand(this._viewModel);

  final LessonViewModel _viewModel;

  @override
  void execute([BuildContext? context]) {
    _viewModel.skipCurrentActivity();
  }
}
