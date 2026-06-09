import 'package:flutter/material.dart';
import 'lesson_activity.dart';

/// Modelo que representa un nodo de leccion dentro del mapa de progreso.
///
/// Cada nodo contiene su propia lista de [LessonActivity] que el usuario debe
/// completar secuencialmente. Cuando todas las actividades están resueltas,
/// el nodo se marca como completado.
class LessonNode {
  /// Crea un nodo de leccion con su metadata, posicion y actividades.
  const LessonNode({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.position,
    required this.activities,
  });

  /// Identificador unico del nodo.
  final String id;

  /// Titulo visible de la leccion.
  final String title;

  /// Tipo visual del nodo dentro del mapa.
  final LessonNodeType type;

  /// Estado actual de la leccion.
  final NodeStatus status;

  /// Posicion dentro del mapa, expresada como coordenadas relativas.
  final Offset position;

  /// Lista de actividades que componen esta leccion.
  final List<LessonActivity> activities;

  /// Construye un [LessonNode] desde un mapa JSON devuelto por la API.
  factory LessonNode.fromJson(Map<String, dynamic> json) {
    return LessonNode(
      id: json['id'] as String,
      title: json['title'] as String,
      type: LessonNodeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => LessonNodeType.star,
      ),
      status: NodeStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => NodeStatus.locked,
      ),
      position: Offset(
        (json['positionX'] as num?)?.toDouble() ?? 0,
        (json['positionY'] as num?)?.toDouble() ?? 0,
      ),
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) =>
                  LessonActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Serializa este nodo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'status': status.name,
      'positionX': position.dx,
      'positionY': position.dy,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  /// Crea una copia del nodo actualizando solo los campos indicados.
  LessonNode copyWith({
    String? id,
    String? title,
    LessonNodeType? type,
    NodeStatus? status,
    Offset? position,
    List<LessonActivity>? activities,
  }) {
    return LessonNode(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      position: position ?? this.position,
      activities: activities ?? this.activities,
    );
  }
}

/// Tipos visuales soportados para un nodo de leccion.
enum LessonNodeType {
  /// Nodo con iconografia de estrella.
  star,

  /// Nodo con iconografia de libro.
  book,

  /// Nodo con iconografia de fuerza o entrenamiento.
  dumbbell,

  /// Nodo especial de boss o cierre de etapa.
  boss,
}

/// Estados de avance de una leccion en el mapa.
enum NodeStatus {
  /// La leccion ya fue completada por el usuario.
  completed,

  /// La leccion es la activa actual y puede abrirse.
  active,

  /// La leccion esta bloqueada y no es interactiva.
  locked,
}
