import '../core/base_viewmodel.dart';
import '../core/mock_database.dart';
import '../core/service_locator.dart';
import '../models/onboarding_question.dart';
import '../repositories/user_repository.dart';

/// ViewModel encargada de controlar el wizard de onboarding y su registro final.
class OnboardingViewModel extends BaseViewModel {
  /// Crea la ViewModel del onboarding con repositorio opcional inyectado.
  OnboardingViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository {
    _questions = const [
      OnboardingQuestion(
        title: '¿Qué te gustaría aprender?',
        animationPath: 'assets/lottie/cat_happy.json',
        options: ['Inglés', 'Francés', 'Italiano', 'Alemán', 'Portugués'],
      ),
      OnboardingQuestion(
        title: '¿Cómo supiste de Duolingo?',
        animationPath: 'assets/lottie/Cat_typing.json',
        options: ['Amigos/familia', 'Búsqueda en Google', 'Facebook/Instagram', 'YouTube', 'Noticias/artículos/blog'],
      ),
      OnboardingQuestion(
        title: '¿Cuánto inglés sabes?',
        animationPath: 'assets/lottie/cat_idle.json',
        options: [
          'Estoy empezando a aprender inglés',
          'Conozco algunas palabras comunes',
          'Puedo mantener conversaciones simples',
          'Puedo conversar sobre varios temas',
          'Puedo debatir en detalle sobre la mayoría de los temas',
        ],
      ),
      OnboardingQuestion(
        title: '¿Cuál es tu meta diaria de aprendizaje?',
        animationPath: 'assets/lottie/cat_sleeping.json',
        options: ['3 min/día', '10 min/día', '15 min/día', '30 min/día'],
      ),
      OnboardingQuestion(
        title: '¿Cuál es tu objetivo principal?',
        animationPath: 'assets/lottie/cat_happy.json',
        options: [
          'Para divertirme',
          'Prepararme para viajar',
          'Ejercitar mi mente',
          'Impulsar mis estudios',
          'Impulsar mi carrera profesional',
          'Conectarme con personas',
          'Otros',
        ],
      ),
      OnboardingQuestion(
        title: '¿Qué formato te ayuda más a aprender?',
        animationPath: 'assets/lottie/Cat_in_a_rocket.json',
        options: ['Practicar leyendo', 'Practicar escuchando', 'Hablar con confianza', 'Juegos cortos'],
      ),
      OnboardingQuestion(
        title: '¿Cuándo quieres aprender?',
        animationPath: 'assets/lottie/cat_happy.json',
        options: ['Mañana', 'Tarde', 'Noche'],
      ),
      OnboardingQuestion(
        title: '¿Listo para comenzar tu primera lección?',
        animationPath: 'assets/lottie/cat_happy.json',
        options: ['Sí, empecemos', 'Necesito un poco más'],
      ),
    ];

    _answers = List<String?>.filled(_totalSteps, null);
  }

  final MockUserRepository _userRepository;
  late final List<OnboardingQuestion> _questions;
  late List<String?> _answers;
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
  String? get selectedAnswer => _answers[_currentStep];

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

    _answers[_currentStep] = option;

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

  /// Reinicia el onboarding al primer paso y limpia las respuestas.
  void reset() {
    _currentStep = 0;
    _answers = List<String?>.filled(_totalSteps, null);
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
          (index) => _answers[index] ?? '',
          growable: false,
        ),
      );
      setSuccess();
    } catch (_) {
      setError('No se pudo completar el onboarding. Inténtalo de nuevo.');
    }
  }

  /// Respuesta actual del paso visible.
  String get currentAnswer => _answers[_currentStep] ?? '';
}
