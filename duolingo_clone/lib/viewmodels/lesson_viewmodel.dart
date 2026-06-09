import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../core/api_client.dart';
import '../core/base_viewmodel.dart';
import '../core/audio_service.dart';
import '../core/mock_database.dart';
import '../core/service_locator.dart';
import '../models/lesson_activity.dart';
import '../repositories/user_repository.dart';

enum LessonState {
  loading,
  ready,
  error,
  gameOver,
}

class LessonViewModel extends BaseViewModel {
  LessonViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  List<LessonActivity> _activities = const [];
  int _currentActivityIndex = 0;
  bool _isChecking = false;
  bool _isCorrect = false;
  String _selectedAnswer = '';
  int _currentHearts = 5;
  bool _isPracticeMode = false;
  LessonState _state = LessonState.ready;
  String? _currentNodeId;

  List<LessonActivity> get activities => _activities;
  int get currentActivityIndex => _currentActivityIndex;
  int get totalActivities => _activities.length;
  String? get currentNodeId => _currentNodeId;
  LessonState get state => _state;
  int get lessonsCompleted => ServiceLocator.completedLessonsCount;
  int get currentHearts => _currentHearts;
  bool get isGameOver => _currentHearts <= 0;
  bool get isChecking => _isChecking;
  bool get isCorrect => _isCorrect;
  String get selectedAnswer => _selectedAnswer;

  String get currentAiExplanation {
    final activity = currentActivityOrNull;
    if (activity == null) {
      return 'No hay una actividad activa para explicar en este momento.';
    }
    return activity.aiExplanation ??
        'Revisa la estructura de la oración, el contexto y la forma gramatical de cada opción para encontrar la respuesta correcta.';
  }

  double get progress {
    return _activities.isNotEmpty
        ? _currentActivityIndex / _activities.length
        : 0;
  }

  LessonActivity get currentActivity {
    if (_activities.isEmpty || _currentActivityIndex >= _activities.length) {
      throw StateError(
          'No hay actividades disponibles para el índice $_currentActivityIndex.');
    }
    return _activities[_currentActivityIndex];
  }

  LessonActivity? get currentActivityOrNull {
    if (_activities.isEmpty || _currentActivityIndex >= _activities.length) {
      return null;
    }
    return _activities[_currentActivityIndex];
  }

  Future<void> loadLesson(String nodeId) async {
    _setState(LessonState.loading);
    _resetGameState();
    _currentNodeId = nodeId;

    try {
      List<LessonActivity> nodeActivities;

      if (_isFirebaseUser()) {
        final response =
            await ApiClient.instance.get('/api/v1/lessons/$nodeId/activities');
        final list = response.data as List;
        nodeActivities = list
            .map((e) => LessonActivity.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        nodeActivities =
            MockDatabase.instance.getActivitiesForNode(nodeId);
      }

      if (nodeActivities.isEmpty) {
        _setState(LessonState.error);
        return;
      }

      _activities = nodeActivities;
      _currentActivityIndex = 0;
      _isPracticeMode = false;
      _currentHearts = 5;
      _setState(LessonState.ready);
    } catch (_) {
      _setState(LessonState.error);
    }
  }

  Future<void> loadPracticeLesson(String category) async {
    _setState(LessonState.loading);
    _resetGameState();
    _currentNodeId = null;

    try {
      List<LessonActivity> filtered;

      if (_isFirebaseUser()) {
        final response = await ApiClient.instance
            .get('/api/v1/lessons/practice', params: {'category': category});
        final list = response.data as List;
        filtered = list
            .map((e) => LessonActivity.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final allActivities = MockDatabase.instance.practicePool;
        filtered = allActivities
            .where((a) => _matchesCategory(a, category))
            .toList()
          ..shuffle();

        if (filtered.length < 10) {
          final pool = List<LessonActivity>.from(
              MockDatabase.instance.lessonActivities)
            ..shuffle();
          filtered.addAll(pool.take(10 - filtered.length));
        }
        filtered = filtered.take(10).toList();
      }

      _activities = filtered;
      _currentActivityIndex = 0;
      _isPracticeMode = true;
      // Modo práctica: vidas infinitas
      _currentHearts = 999;
      _setState(LessonState.ready);
    } catch (_) {
      _setState(LessonState.error);
    }
  }

  void setSelectedAnswer(String answer) {
    _selectedAnswer = answer;
    notifyListeners();
  }

  Future<bool> checkAnswer(String userAnswer) async {
    if (_activities.isEmpty) return false;

    _isChecking = true;
    notifyListeners();

    _isCorrect = userAnswer.trim().toLowerCase() ==
        currentActivity.correctAnswer.trim().toLowerCase();

    // Modo práctica: nunca se descuentan corazones
    if (!_isCorrect && _currentHearts > 0 && !_isPracticeMode) {
      _currentHearts--;
      await _userRepository.decrementHearts();
    }

    _isChecking = false;
    notifyListeners();

    if (_currentHearts <= 0 && !_isPracticeMode) {
      _setState(LessonState.gameOver);
    }

    return _isCorrect;
  }

  /// Avanza al siguiente índice de actividad.
  ///
  /// Incrementa [_currentActivityIndex]. Si aún quedan actividades en la
  /// lección, la UI se actualiza con la siguiente pregunta. Si ya no quedan
  /// más, marca la lección como completada y la navegación la dirige a
  /// [LessonCompleteScreen].
  void nextActivity() {
    if (_activities.isEmpty) return;

    _currentActivityIndex++;

    if (_currentActivityIndex < _activities.length) {
      _isChecking = false;
      _isCorrect = false;
      _selectedAnswer = '';
      notifyListeners();
      _playAudioIfNeeded(currentActivity);
      return;
    }

    ServiceLocator.incrementCompletedLessons();
    _userRepository.addXpToCurrentUser(10);
    setSuccess();
  }

  void skipCurrentActivity() {
    if (_activities.isEmpty) return;
    _isChecking = false;
    _isCorrect = false;
    _selectedAnswer = '';
    nextActivity();
  }

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
    _currentHearts = 5;
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

  bool _isFirebaseUser() {
    try {
      return fb.FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  void _playAudioIfNeeded(LessonActivity activity) {
    if (!_isAuditory(activity)) return;
    final text = _resolveAudioText(activity);
    AudioService.instance.speak(text);
  }

  bool _isAuditory(LessonActivity activity) {
    return activity.type == ActivityType.listenSelect ||
        activity.type == ActivityType.repeat;
  }

  String _resolveAudioText(LessonActivity activity) {
    final payload = activity.payload;
    if (payload is Map) {
      final subtitle =
          payload['subtitle'] ?? payload['audioText'] ?? payload['sentence'];
      if (subtitle is String && subtitle.trim().isNotEmpty) {
        return subtitle.trim();
      }
    }
    return activity.prompt;
  }

  bool _matchesCategory(LessonActivity activity, String categoryLabel) {
    final ActivityType? expectedType = _categoryToType(categoryLabel);
    if (expectedType != null && activity.type == expectedType) {
      return true;
    }
    return activity.category?.toLowerCase() == categoryLabel.toLowerCase();
  }

  ActivityType? _categoryToType(String label) {
    switch (label.toLowerCase()) {
      case 'listening':
        return ActivityType.listenSelect;
      case 'speaking':
        return ActivityType.repeat;
      case 'grammar':
        return ActivityType.fillBlank;
      case 'translation':
        return ActivityType.selectTranslation;
      default:
        return null;
    }
  }
}
