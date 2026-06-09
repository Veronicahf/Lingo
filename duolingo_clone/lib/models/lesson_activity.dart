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

  /// Construye una [LessonActivity] desde un mapa JSON devuelto por la API.
  factory LessonActivity.fromJson(Map<String, dynamic> json) {
    return LessonActivity(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ActivityType.selectTranslation,
      ),
      prompt: json['prompt'] as String,
      payload: json['payload'],
      correctAnswer: json['correctAnswer'] as String,
      aiExplanation: json['aiExplanation'] as String?,
      mascotEmotion: (json['mascotEmotion'] as String?) ?? 'idle',
      category: json['category'] as String?,
    );
  }

  /// Serializa esta actividad a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'prompt': prompt,
      'payload': payload,
      'correctAnswer': correctAnswer,
      'aiExplanation': aiExplanation,
      'mascotEmotion': mascotEmotion,
      'category': category,
    };
  }
}
