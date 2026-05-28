import '../core/base_viewmodel.dart';
import '../core/audio_service.dart';
import '../core/mock_database.dart';
import '../models/lesson_activity.dart';

/// ViewModel que controla el flujo de una leccion basada en actividades.
///
/// Esta capa actua como el cerebro de la leccion: toma los juegos mock desde la base en memoria,
/// administra el indice actual, valida respuestas y notifica a la vista cuando el estado cambia.
class LessonViewModel extends BaseViewModel {
  List<LessonActivity> _activities = const [];
  int _currentIndex = 0;
  bool _isChecking = false;
  bool _isCorrect = false;
  String _selectedAnswer = '';

  /// Lista de actividades cargadas para la leccion actual.
  List<LessonActivity> get activities => _activities;

  /// Indice de la actividad visible en este momento.
  int get currentIndex => _currentIndex;

  /// Indica si la leccion esta ejecutando una validacion.
  bool get isChecking => _isChecking;

  /// Indica si la ultima respuesta fue correcta.
  bool get isCorrect => _isCorrect;

  /// Respuesta temporal seleccionada por el usuario en la actividad actual.
  String get selectedAnswer => _selectedAnswer;

  /// Texto mock que simula la explicación generada por una IA para la actividad actual.
  ///
  /// TODO: Consumir API de LLM en Spring Boot para generar explicación en tiempo real
  String get currentAiExplanation {
    if (_activities.isEmpty) {
      return 'No hay una actividad activa para explicar en este momento.';
    }

    return currentActivity.aiExplanation ??
        'Revisa la estructura de la oración, el contexto y la forma gramatical de cada opción para encontrar la respuesta correcta.';
  }

  /// Progreso de la leccion expresado como fraccion del total de actividades.
  double get progress => _currentIndex / _activities.length;

  /// Actividad que debe renderizarse en la pantalla.
  LessonActivity get currentActivity => _activities[_currentIndex];

  /// Carga las actividades mock del motor de leccion y reinicia el estado de juego.
  void loadLesson() {
    resetState();
    _activities = List<LessonActivity>.unmodifiable(MockDatabase.instance.lessonActivities);
    _currentIndex = 0;
    _isChecking = false;
    _isCorrect = false;
    _selectedAnswer = '';
    notifyListeners();
  }

  /// Guarda la respuesta seleccionada por el usuario para la actividad actual.
  void setSelectedAnswer(String answer) {
    _selectedAnswer = answer;
    notifyListeners();
  }

  /// Compara la respuesta del usuario con la solucion correcta y actualiza el estado.
  Future<void> checkAnswer(String userAnswer) async {
    if (_activities.isEmpty) {
      return;
    }

    _isChecking = true;
    notifyListeners();

    _isCorrect = userAnswer.trim().toLowerCase() == currentActivity.correctAnswer.trim().toLowerCase();
    _isChecking = false;
    notifyListeners();
  }

  /// Avanza a la siguiente actividad o marca la leccion como completada.
  void nextActivity() {
    if (_activities.isEmpty) {
      return;
    }

    // Si no es la última actividad, avanza y reproduce audio si es necesario
    if (_currentIndex < _activities.length - 1) {
      _currentIndex++;
      _isChecking = false;
      _isCorrect = false;
      _selectedAnswer = '';
      notifyListeners();
      _playAudioIfNeeded(currentActivity);
      return;
    }

    // Última actividad: marca como completada
    _isChecking = false;
    _isCorrect = false;
    _selectedAnswer = '';
    setSuccess(); // Notifica que la lección está completada
  }

  /// Marca la actividad actual como saltada y avanza al siguiente paso del flujo.
  void skipCurrentActivity() {
    if (_activities.isEmpty) {
      return;
    }

    _isChecking = false;
    _isCorrect = false;
    _selectedAnswer = '';
    nextActivity();
  }

  void _playAudioIfNeeded(LessonActivity activity) {
    if (!_isAuditory(activity)) {
      return;
    }

    final String audioText = _resolveAudioText(activity);
    AudioService.instance.speak(audioText);
  }

  bool _isAuditory(LessonActivity activity) {
    return activity.type == ActivityType.listenSelect || activity.type == ActivityType.repeat;
  }

  String _resolveAudioText(LessonActivity activity) {
    final dynamic payload = activity.payload;

    if (payload is Map) {
      final dynamic subtitle = payload['subtitle'] ?? payload['audioText'] ?? payload['sentence'];
      if (subtitle is String && subtitle.trim().isNotEmpty) {
        return subtitle.trim();
      }
    }

    return activity.prompt;
  }
}