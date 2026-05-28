/// Modelo que representa una pregunta del onboarding con sus opciones de respuesta.
class OnboardingQuestion {
  /// Crea una pregunta del wizard de onboarding.
  const OnboardingQuestion({
    required this.title,
    required this.animationPath,
    required this.options,
  });

  /// Texto principal que se muestra como pregunta.
  final String title;

  /// Ruta del Lottie que acompaña visualmente a la pregunta.
  final String animationPath;

  /// Lista de opciones disponibles para responder.
  final List<String> options;
}
