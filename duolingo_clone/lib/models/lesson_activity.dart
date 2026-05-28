/// Tipos de actividades soportadas por el motor de lecciones.
enum ActivityType {
  /// Actividad de completar un dialogo.
  completeDialog,

  /// Actividad de completar un espacio en blanco.
  fillBlank,

  /// Actividad de escuchar y seleccionar.
  listenSelect,

  /// Actividad de repetir una frase.
  repeat,

  /// Actividad de emparejar pares.
  matchPairs,

  /// Actividad de seleccionar una traduccion.
  selectTranslation,

  /// Actividad de traducir una oracion.
  translateSentence,
}

/// Representa una actividad individual dentro de una leccion.
///
/// Este modelo encapsula el tipo de juego, su instruccion visible y un payload
/// flexible con los datos especificos que cada actividad necesita para renderizarse.
class LessonActivity {
  /// Crea una actividad de leccion con su metadata y datos especificos.
  const LessonActivity({
    required this.id,
    required this.type,
    required this.prompt,
    required this.payload,
    required this.correctAnswer,
    this.aiExplanation,
  });

  /// Identificador unico de la actividad.
  final String id;

  /// Tipo de actividad a renderizar.
  final ActivityType type;

  /// Instruccion visible para el usuario.
  final String prompt;

  /// Datos especificos de la actividad, normalmente en formato JSON o mapa.
  final dynamic payload;

  /// Respuesta correcta esperada por el motor de validacion.
  final String correctAnswer;

  /// Explicación opcional simulada por IA para ayudar al usuario a entender el error.
  final String? aiExplanation;
}
