import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/onboarding_question.dart';

/// ViewModel encargada de controlar el wizard de onboarding.
///
/// "Empezar ahora" solo recolecta las respuestas del usuario. El registro
/// completo (nombre, correo, contraseña) se dispara al completar la lección 2
/// o al intentar acceder a Ranking/Perfil sin haber finalizado el registro.
class OnboardingViewModel extends BaseViewModel {
  OnboardingViewModel()
      : _questions = ServiceLocator.userRepository.getOnboardingQuestions(),
        _answers = List<List<String>>.generate(_totalSteps, (_) => <String>[]);

  late final List<OnboardingQuestion> _questions;
  late List<List<String>> _answers;

  static const int _totalSteps = 8;

  /// Preguntas disponibles para el onboarding.
  List<OnboardingQuestion> get questions =>
      List<OnboardingQuestion>.unmodifiable(_questions);

  /// Paso actual del wizard, empezando en cero.
  int _currentStep = 0;

  /// Paso actual visible en la UI.
  int get currentStep => _currentStep;

  /// Total de pasos del wizard.
  int get totalSteps => _totalSteps;

  /// Pregunta actual que se muestra en pantalla.
  OnboardingQuestion get currentQuestion {
    if (_questions.isEmpty || _currentStep >= _questions.length) {
      throw StateError(
          'No hay preguntas de onboarding para el paso $_currentStep.');
    }
    return _questions[_currentStep];
  }

  /// Respuesta seleccionada para el paso actual, si existe.
  String? get selectedAnswer =>
      _answers[_currentStep].isEmpty ? null : _answers[_currentStep].first;

  /// Respuestas seleccionadas para el paso actual.
  List<String> get selectedAnswers =>
      List<String>.unmodifiable(_answers[_currentStep]);

  /// Progreso normalizado del wizard.
  double get progress => (_currentStep + 1) / _totalSteps;

  /// Indica si la pregunta actual es la última del flujo.
  bool get isLastStep => _currentStep == _totalSteps - 1;

  /// Indica si el onboarding está procesando.
  bool get isProcessing => isLoading;

  /// Todas las respuestas recolectadas durante el onboarding.
  List<List<String>> get allAnswers =>
      _answers.map((a) => List<String>.unmodifiable(a)).toList();

  /// Curso inferido de las respuestas (primera pregunta).
  String get resolvedCourseId => _resolveCourseId(
        _answers.first.isEmpty ? '' : _answers.first.first,
      );

  /// Selecciona una opción, avanza automáticamente en pasos de selección única
  /// y en el último paso solo recolecta sin registrar.
  Future<void> selectOption(String option) async {
    if (isLoading) {
      return;
    }

    final currentAnswers = _answers[_currentStep];

    if (currentQuestion.allowMultipleSelection) {
      if (currentAnswers.contains(option)) {
        currentAnswers.remove(option);
      } else {
        currentAnswers.add(option);
      }

      notifyListeners();
      return;
    }

    _answers[_currentStep] = <String>[option];

    if (isLastStep) {
      return;
    }

    nextStep();
  }

  /// Avanza al siguiente paso si todavía quedan preguntas.
  void nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Retrocede un paso si el wizard todavía no está en el inicio.
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Continúa al siguiente paso o finaliza la recolección si es el último.
  Future<void> continueStep() async {
    if (isLoading) {
      return;
    }

    if (isLastStep) {
      await completeCollection();
      return;
    }

    nextStep();
  }

  /// Finaliza la recolección de datos del onboarding sin registrar al usuario.
  ///
  /// Marca la recolección como exitosa para que la UI navegue al home,
  /// pero el usuario aún no está persistido. El registro real ocurre cuando
  /// se complete la lección 2 o al intentar acceder a Ranking/Perfil.
  Future<void> completeCollection() async {
    if (isLoading) {
      return;
    }

    setLoading(true);

    try {
      // Solo marca éxito — no crea usuario ni persiste nada
      await Future<void>.delayed(const Duration(milliseconds: 300));
      setSuccess();
    } catch (_) {
      setError('No se pudieron guardar tus respuestas. Inténtalo de nuevo.');
    }
  }

  /// Reinicia el onboarding al primer paso y limpia las respuestas.
  void reset() {
    _currentStep = 0;
    _answers = List<List<String>>.generate(_totalSteps, (_) => <String>[]);
    resetState();
  }

  String _resolveCourseId(String selectedOption) {
    switch (selectedOption.trim().toLowerCase()) {
      case 'francés':
        return 'course_fr';
      case 'italiano':
        return 'course_it';
      default:
        return 'course_en';
    }
  }

  /// Respuesta actual del paso visible.
  String get currentAnswer => selectedAnswer ?? '';
}
