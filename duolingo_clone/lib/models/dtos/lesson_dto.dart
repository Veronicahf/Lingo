import '../lesson_activity.dart';

/// DTO que transporta los datos de una actividad de lección desde la capa de datos hacia la UI.
///
/// Aísla a la UI de la estructura interna de [LessonActivity] y de la base de datos en memoria,
/// permitiendo que la fuente de datos (mock o API REST futura) pueda cambiar sin afectar la vista.
class LessonDTO {
  const LessonDTO({
    required this.id,
    required this.type,
    required this.prompt,
    required this.payload,
    required this.correctAnswer,
    this.aiExplanation,
    this.mascotEmotion = 'idle',
  });

  /// Identificador único de la actividad.
  final String id;

  /// Tipo de actividad a renderizar.
  final ActivityType type;

  /// Instrucción visible para el usuario.
  final String prompt;

  /// Datos específicos de la actividad.
  final Map<String, dynamic> payload;

  /// Respuesta correcta esperada.
  final String correctAnswer;

  /// Explicación opcional tipo IA.
  final String? aiExplanation;

  /// Emoción de la mascota para la animación Lottie.
  final String mascotEmotion;

  /// Construye un [LessonDTO] desde un mapa JSON (futuro endpoint REST).
  factory LessonDTO.fromJson(Map<String, dynamic> json) {
    return LessonDTO(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ActivityType.selectTranslation,
      ),
      prompt: json['prompt'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      correctAnswer: json['correctAnswer'] as String,
      aiExplanation: json['aiExplanation'] as String?,
      mascotEmotion: json['mascotEmotion'] as String? ?? 'idle',
    );
  }

  /// Construye un [LessonDTO] desde un modelo [LessonActivity] de la base en memoria.
  factory LessonDTO.fromActivity(LessonActivity activity) {
    return LessonDTO(
      id: activity.id,
      type: activity.type,
      prompt: activity.prompt,
      payload: activity.payload is Map<String, dynamic>
          ? Map<String, dynamic>.from(activity.payload as Map)
          : <String, dynamic>{},
      correctAnswer: activity.correctAnswer,
      aiExplanation: activity.aiExplanation,
      mascotEmotion: activity.mascotEmotion,
    );
  }

  /// Serializa este DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'prompt': prompt,
      'payload': payload,
      'correctAnswer': correctAnswer,
      'aiExplanation': aiExplanation,
      'mascotEmotion': mascotEmotion,
    };
  }
}
