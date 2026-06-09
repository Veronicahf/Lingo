import 'dart:async';

import '../core/base_viewmodel.dart';
import '../core/audio_service.dart';
import '../core/mock_database.dart';
import '../core/service_locator.dart';
import '../models/dtos/lesson_response_dto.dart';
import '../models/lesson_activity.dart';
import '../repositories/user_repository.dart';

/// Estados posibles del ciclo de vida de una lección.
enum LessonState {
  loading,
  ready,
  error,
  gameOver,
}

/// ViewModel que controla el flujo de una lección basada en actividades.
///
/// Cada lección corresponde a un [LessonNode] del mapa y contiene su propia
/// lista de [LessonActivity]. El ViewModel carga las actividades del nodo
/// específico, permite navegar entre ellas, y marca la lección como completada
/// cuando el usuario resuelve todas las actividades del nodo.
class LessonViewModel extends BaseViewModel {
  LessonViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  static const int _practiceBufferSize = 10;

  List<LessonActivity> _activities = const [];
  int _currentActivityIndex = 0;
  bool _isChecking = false;
  bool _isCorrect = false;
  String _selectedAnswer = '';
  int _currentHearts = 5;
  bool _isPracticeMode = false;
  LessonState _state = LessonState.ready;
  String? _currentNodeId;

  /// Lista de actividades de la lección actual.
  List<LessonActivity> get activities => _activities;

  /// Índice de la actividad actual dentro de la lección.
  int get currentActivityIndex => _currentActivityIndex;

  /// ID del nodo del mapa que se está jugando actualmente.
  String? get currentNodeId => _currentNodeId;

  /// Estado actual del ciclo de vida de la lección.
  LessonState get state => _state;

  /// Número de lecciones completadas acumuladas (persistente entre sesiones).
  int get lessonsCompleted => ServiceLocator.completedLessonsCount;

  /// Corazones disponibles del usuario.
  int get currentHearts => _currentHearts;

  /// Indica si el usuario se quedó sin vidas.
  bool get isGameOver => _currentHearts <= 0;

  /// Indica si la lección está ejecutando una validación.
  bool get isChecking => _isChecking;

  /// Indica si la última respuesta fue correcta.
  bool get isCorrect => _isCorrect;

  /// Respuesta temporal seleccionada por el usuario en la actividad actual.
  String get selectedAnswer => _selectedAnswer;

  /// Texto mock que simula la explicación generada por una IA.
  String get currentAiExplanation {
    final activity = currentActivityOrNull;
    if (activity == null) {
      return 'No hay una actividad activa para explicar en este momento.';
    }
    return activity.aiExplanation ??
        'Revisa la estructura de la oración, el contexto y la forma gramatical de cada opción para encontrar la respuesta correcta.';
  }

  /// Progreso de la lección expresado como fracción del total de actividades.
  double get progress {
    return _activities.length > 0 ? _currentActivityIndex / _activities.length : 0;
  }

  /// Actividad actual dentro de la lección.
  LessonActivity get currentActivity {
    if (_activities.isEmpty || _currentActivityIndex >= _activities.length) {
      throw StateError('No hay actividades disponibles para el índice $_currentActivityIndex.');
    }
    return _activities[_currentActivityIndex];
  }

  /// Actividad actual o null si la lista está vacía o el índice es inválido.
  LessonActivity? get currentActivityOrNull {
    if (_activities.isEmpty || _currentActivityIndex >= _activities.length) {
      return null;
    }
    return _activities[_currentActivityIndex];
  }

  /// Carga las actividades del nodo especificado y reinicia el estado.
  ///
  /// [nodeId] es el identificador del [LessonNode] en el mapa, cuyas actividades
  /// se cargan desde [MockDatabase].
  Future<void> loadLesson(String nodeId) async {
    _setState(LessonState.loading);
    _resetGameState();
    _currentNodeId = nodeId;

    try {
      final List<LessonActivity> nodeActivities =
          MockDatabase.instance.getActivitiesForNode(nodeId);

      if (nodeActivities.isEmpty) {
        _setState(LessonState.error);
        return;
      }

      _activities = List<LessonActivity>.unmodifiable(nodeActivities);
      _currentActivityIndex = 0;
      _isPracticeMode = false;
      _currentHearts = await _userRepository.getCurrentHearts();
      _setState(LessonState.ready);
    } catch (_) {
      _setState(LessonState.error);
    }
  }

  /// Carga actividades filtradas por categoría para el centro de práctica.
  Future<void> loadPracticeLesson(String category) async {
    _setState(LessonState.loading);
    _resetGameState();
    _currentNodeId = null;

    try {
      final List<LessonActivity> allActivities = MockDatabase.instance.practicePool;
      final List<LessonActivity> filtered = allActivities
          .where((activity) => activity.category?.toLowerCase() == category.toLowerCase())
          .toList()
        ..shuffle();

      if (filtered.length < _practiceBufferSize) {
        final List<LessonActivity> lessonActivities =
            List<LessonActivity>.from(MockDatabase.instance.lessonActivities)
              ..shuffle();
        filtered.addAll(
          lessonActivities.take(_practiceBufferSize - filtered.length),
        );
      }

      _activities = List<LessonActivity>.unmodifiable(
        filtered.take(_practiceBufferSize).toList(),
      );
      _currentActivityIndex = 0;
      _isPracticeMode = true;
      _currentHearts = await _userRepository.getCurrentHearts();

      if (_activities.isEmpty) {
        _setState(LessonState.error);
      } else {
        _setState(LessonState.ready);
      }
    } catch (_) {
      _setState(LessonState.error);
    }
  }

  /// Guarda la respuesta seleccionada por el usuario para la actividad actual.
  void setSelectedAnswer(String answer) {
    _selectedAnswer = answer;
    notifyListeners();
  }

  /// Valida la respuesta del usuario y retorna un [LessonResponseDTO] estructurado.
  Future<LessonResponseDTO> checkAnswer(String userAnswer) async {
    if (_activities.isEmpty) {
      return LessonResponseDTO(
        xpEarned: 0,
        heartsRemaining: _currentHearts,
        status: LessonStatus.inProgress,
      );
    }

    _isChecking = true;
    notifyListeners();

    _isCorrect = userAnswer.trim().toLowerCase() ==
        currentActivity.correctAnswer.trim().toLowerCase();

    if (!_isCorrect && _currentHearts > 0) {
      _currentHearts--;
      await _userRepository.decrementHearts();
    }

    _isChecking = false;
    notifyListeners();

    final bool isGameOverNow = _currentHearts <= 0;
    if (isGameOverNow) {
      _setState(LessonState.gameOver);
    }

    return LessonResponseDTO(
      xpEarned: 0,
      heartsRemaining: _currentHearts,
      status: isGameOverNow ? LessonStatus.inProgress : LessonStatus.inProgress,
    );
  }

  /// Avanza a la siguiente actividad.
  ///
  /// Si se supera el total de actividades de la lección, se marca como completada.
  Future<void> nextActivity() async {
    if (_activities.isEmpty) {
      return;
    }

    final int nextIndex = _currentActivityIndex + 1;

    // Si hay más actividades en la lección, avanza
    if (nextIndex < _activities.length) {
      _currentActivityIndex = nextIndex;
      _isChecking = false;
      _isCorrect = false;
      _selectedAnswer = '';
      notifyListeners();
      _playAudioIfNeeded(currentActivity);
      return;
    }

    // Modo práctica: reshuffle y reinicia
    if (_isPracticeMode) {
      final List<LessonActivity> refreshed =
          List<LessonActivity>.from(_activities)..shuffle();
      _activities = List<LessonActivity>.unmodifiable(refreshed);
      _currentActivityIndex = 0;
      _isChecking = false;
      _isCorrect = false;
      _selectedAnswer = '';
      await _userRepository.addXpToCurrentUser(1);
      notifyListeners();
      _playAudioIfNeeded(currentActivity);
      return;
    }

    // Lección completada: todas las actividades del nodo resueltas
    _isChecking = false;
    _isCorrect = false;
    _selectedAnswer = '';
    ServiceLocator.incrementCompletedLessons();
    await _userRepository.addXpToCurrentUser(10);
    setSuccess(); // Marca que la lección está completada
  }

  /// Marca la actividad actual como saltada y avanza al siguiente paso.
  void skipCurrentActivity() {
    if (_activities.isEmpty) {
      return;
    }
    _isChecking = false;
    _isCorrect = false;
    _selectedAnswer = '';
    nextActivity();
  }

  /// Reinicia el estado interno.
  void resetLesson() {
    _resetGameState();
    _activities = const [];
    _currentNodeId = null;
    notifyListeners();
  }

  void _resetGameState() {
    _currentActivityIndex = 0;
    _isPracticeMode = false;
    _isChecking = false;
    _isCorrect = false;
    _selectedAnswer = '';
  }

  void _setState(LessonState newState) {
    _state = newState;
    if (newState == LessonState.loading) {
      setLoading(true);
    } else if (newState == LessonState.error) {
      setError('No se pudo cargar la lección.');
    } else if (newState == LessonState.gameOver) {
      setLoading(false);
      setSuccess();
    }
    notifyListeners();
  }

  void _playAudioIfNeeded(LessonActivity activity) {
    if (!_isAuditory(activity)) {
      return;
    }
    final String audioText = _resolveAudioText(activity);
    AudioService.instance.speak(audioText);
  }

  bool _isAuditory(LessonActivity activity) {
    return activity.type == ActivityType.listenSelect ||
        activity.type == ActivityType.repeat;
  }

  String _resolveAudioText(LessonActivity activity) {
    final dynamic payload = activity.payload;
    if (payload is Map) {
      final dynamic subtitle =
          payload['subtitle'] ?? payload['audioText'] ?? payload['sentence'];
      if (subtitle is String && subtitle.trim().isNotEmpty) {
        return subtitle.trim();
      }
    }
    return activity.prompt;
  }
}
