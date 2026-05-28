/// Modelo que representa una opcion del onboarding.
class OnboardingOption {
  /// Crea una opcion de onboarding.
  const OnboardingOption({
    required this.text,
    this.isEnabled = true,
    this.iconPath,
  });

  /// Texto visible de la opcion.
  final String text;

  /// Indica si la opcion puede seleccionarse.
  final bool isEnabled;

  /// Ruta opcional de un icono o imagen para la opcion.
  final String? iconPath;
}

/// Modelo que representa una pregunta del onboarding con sus opciones de respuesta.
class OnboardingQuestion {
  /// Crea una pregunta del wizard de onboarding.
  const OnboardingQuestion({
    required this.title,
    required this.animationPath,
    required this.options,
    this.allowMultipleSelection = false,
  });

  /// Texto principal que se muestra como pregunta.
  final String title;

  /// Ruta del Lottie que acompaña visualmente a la pregunta.
  final String animationPath;

  /// Lista de opciones disponibles para responder.
  final List<OnboardingOption> options;

  /// Indica si la pregunta permite seleccionar más de una opción.
  final bool allowMultipleSelection;
}
