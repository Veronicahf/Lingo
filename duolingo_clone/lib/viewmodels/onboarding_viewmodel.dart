import '../core/base_viewmodel.dart';
import '../core/mock_database.dart';
import '../core/service_locator.dart';
import '../models/onboarding_question.dart';
import '../repositories/user_repository.dart';

/// ViewModel encargada de controlar el wizard de onboarding y su registro final.
class OnboardingViewModel extends BaseViewModel {
  /// Crea la ViewModel del onboarding con repositorio opcional inyectado.
  OnboardingViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository,
        _questions = MockDatabase.instance.onboardingQuestions,
        _answers = List<List<String>>.generate(_totalSteps, (_) => <String>[]);

  final MockUserRepository _userRepository;
  late final List<OnboardingQuestion> _questions;
  late List<List<String>> _answers;
  User? _createdUser;

  static const int _totalSteps = 8;

  /// Preguntas disponibles para el onboarding.
  List<OnboardingQuestion> get questions => List<OnboardingQuestion>.unmodifiable(_questions);

  /// Paso actual del wizard, empezando en cero.
  int _currentStep = 0;

  /// Paso actual visible en la UI.
  int get currentStep => _currentStep;

  /// Total de pasos del wizard.
  int get totalSteps => _totalSteps;

  /// Pregunta actual que se muestra en pantalla.
  OnboardingQuestion get currentQuestion => _questions[_currentStep];

  /// Respuesta seleccionada para el paso actual, si existe.
  String? get selectedAnswer => _answers[_currentStep].isEmpty ? null : _answers[_currentStep].first;

  /// Respuestas seleccionadas para el paso actual.
  List<String> get selectedAnswers => List<String>.unmodifiable(_answers[_currentStep]);

  /// Usuario creado al terminar el onboarding, si ya se completó.
  User? get createdUser => _createdUser;

  /// Progreso normalizado del wizard.
  double get progress => (_currentStep + 1) / _totalSteps;

  /// Indica si la pregunta actual es la última del flujo.
  bool get isLastStep => _currentStep == _totalSteps - 1;

  /// Indica si el onboarding está en proceso de registro.
  bool get isRegistering => isLoading;

  /// Selecciona una opción, avanza automáticamente y registra al usuario en el último paso.
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
      await _completeOnboarding();
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

  /// Continúa al siguiente paso o completa el onboarding si corresponde.
  Future<void> continueStep() async {
    if (isLoading) {
      return;
    }

    if (isLastStep) {
      await _completeOnboarding();
      return;
    }

    nextStep();
  }

  /// Reinicia el onboarding al primer paso y limpia las respuestas.
  void reset() {
    _currentStep = 0;
    _answers = List<List<String>>.generate(_totalSteps, (_) => <String>[]);
    _createdUser = null;
    resetState();
  }

  /// Completa el onboarding creando el usuario en la base en memoria.
  Future<void> _completeOnboarding() async {
    setLoading(true);

    try {
      _createdUser = await _userRepository.registerNewUser(
        onboardingAnswers: List<String>.generate(
          _totalSteps,
          (index) => _answers[index].join(', '),
          growable: false,
        ),
      );
      setSuccess();
    } catch (_) {
      setError('No se pudo completar el onboarding. Inténtalo de nuevo.');
    }
  }

  /// Respuesta actual del paso visible.
  String get currentAnswer => selectedAnswer ?? '';
}
