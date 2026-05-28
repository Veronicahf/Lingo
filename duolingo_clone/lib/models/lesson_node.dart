import 'package:flutter/material.dart';

/// Modelo que representa un nodo de leccion dentro del mapa de progreso.
///
/// Esta entidad centraliza el identificador, contenido, tipo y posicion visual de cada punto
/// del recorrido para que la vista construya el mapa desde datos y no desde valores quemados.
class LessonNode {
  /// Crea un nodo de leccion con su metadata y posicion.
  const LessonNode({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.position,
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