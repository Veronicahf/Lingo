/// Estado posible de una lección tras validar la respuesta del usuario.
enum LessonStatus {
  /// La lección fue completada exitosamente.
  completed,

  /// La lección sigue en progreso.
  inProgress,
}

/// DTO que encapsula el resultado de validar una actividad.
///
/// Toda validación de respuesta debe retornar esta estructura para que la UI
/// pueda reaccionar de forma genérica sin depender de la lógica interna.
class LessonResponseDTO {
  const LessonResponseDTO({
    required this.xpEarned,
    required this.heartsRemaining,
    required this.status,
  });

  /// Experiencia ganada en esta validación.
  final int xpEarned;

  /// Corazones restantes después de la validación.
  final int heartsRemaining;

  /// Estado de la lección tras validar.
  final LessonStatus status;

  /// Construye un [LessonResponseDTO] desde un mapa JSON.
  factory LessonResponseDTO.fromJson(Map<String, dynamic> json) {
    return LessonResponseDTO(
      xpEarned: json['xpEarned'] as int,
      heartsRemaining: json['heartsRemaining'] as int,
      status: json['status'] == 'completed'
          ? LessonStatus.completed
          : LessonStatus.inProgress,
    );
  }

  /// Serializa este DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'xpEarned': xpEarned,
      'heartsRemaining': heartsRemaining,
      'status': status == LessonStatus.completed ? 'completed' : 'in_progress',
    };
  }
}
