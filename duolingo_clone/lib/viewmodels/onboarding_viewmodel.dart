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
      await finishOnboarding();
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

  /// Completa el onboarding creando y registrando el usuario en la base en memoria.
  Future<void> finishOnboarding() async {
    if (isLoading) {
      return;
    }

    setLoading(true);

    try {
      final String courseId = _resolveCourseId(_answers.first.isEmpty ? '' : _answers.first.first);
      final User newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: '$courseId.onboarding@lingo.local',
        passwordHash: 'onboarding',
        name: _buildUserName(courseId),
        avatarUrl: 'https://placehold.co/256x256/png?text=New',
        streakDays: 0,
        gems: 500,
        totalXp: 0,
        hearts: 5,
        currentCourseId: courseId,
      );

      _createdUser = await _userRepository.registerUser(newUser);
      setSuccess();
    } catch (_) {
      setError('No se pudo completar el onboarding. Inténtalo de nuevo.');
    }
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

  String _buildUserName(String courseId) {
    switch (courseId) {
      case 'course_fr':
        return 'Aprendiz de Francés';
      case 'course_it':
        return 'Aprendiz de Italiano';
      default:
        return 'Aprendiz de Inglés';
    }
  }

  /// Respuesta actual del paso visible.
  String get currentAnswer => selectedAnswer ?? '';
}
