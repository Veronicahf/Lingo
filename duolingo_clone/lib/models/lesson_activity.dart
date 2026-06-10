/// Tipos de actividades soportadas por el motor de lecciones.
enum ActivityType {
  /// Actividad de traducir una oracion.
  translateSentence,

  /// Actividad de escuchar y seleccionar.
  listenSelect,

  /// Actividad de completar un espacio en blanco.
  fillBlank,

  /// Actividad de repetir una frase en voz alta.
  speaking,

  /// Actividad de seleccionar una traduccion.
  selectTranslation,

  /// Tipo desconocido o no soportado (fallback seguro desde JSON).
  unknown,
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
    this.mascotEmotion = 'idle',
    this.category,
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

  /// Estado emocional de la mascota para elegir la animacion Lottie apropiada.
  final String mascotEmotion;

  /// Categoria opcional para filtrar actividades en el centro de practica.
  final String? category;

  /// Construye una [LessonActivity] desde un mapa JSON.
  ///
  /// Si el tipo es nulo o desconocido, se asigna [ActivityType.unknown]
  /// para evitar que la aplicacion crashee con datos invalidos de la API.
  factory LessonActivity.fromJson(Map<String, dynamic> json) {
    final ActivityType resolvedType;
    final dynamic rawType = json['type'];

    if (rawType is String) {
      resolvedType = ActivityType.values.firstWhere(
        (t) => t.name == rawType,
        orElse: () => ActivityType.unknown,
      );
    } else {
      resolvedType = ActivityType.unknown;
    }

    final Map<String, dynamic> mapPayload =
        (json['payload'] is Map) ? Map<String, dynamic>.from(json['payload']) : {};

    return LessonActivity(
      id: (json['id'] as String?) ?? '',
      type: resolvedType,
      prompt: (json['prompt'] as String?) ??
          (mapPayload['prompt'] as String?) ??
          (mapPayload['sentence'] as String?) ??
          (mapPayload['question'] as String?) ??
          'Traduce esto:',
      payload: json['payload'],
      correctAnswer: (json['correctAnswer'] as String?) ??
          (json['correct_answer'] as String?) ??
          (json['answer'] as String?) ??
          (mapPayload['correctAnswer'] as String?) ??
          (mapPayload['targetSentence'] as String?) ??
          (mapPayload['answer'] as String?) ??
          'Respuesta de emergencia',
      aiExplanation: json['aiExplanation'] as String?,
      mascotEmotion: (json['mascotEmotion'] as String?) ?? 'idle',
      category: json['category'] as String?,
    );
  }
}
