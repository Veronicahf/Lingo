import 'package:flutter/material.dart';

import '../core/mock_database.dart';
import '../models/lesson_node.dart';

// TODO: Conectar a API Spring Boot real.
/// Repositorio simulado que entrega el mapa de lecciones desde datos locales.
///
/// Esta implementacion mantiene el Home desacoplado de la fuente real de datos mientras se
/// desarrolla la integracion con la API.
class MockCourseRepository {
  /// Crea un repositorio mock de cursos.
  const MockCourseRepository();

  // TODO: Consumir API de Spring Boot cuando el backend de cursos este disponible.
  /// Obtiene una lista falsa de nodos de leccion para simular un mapa completo.
  Future<List<LessonNode>> getLessonNodes() async {
    return [
      LessonNode(
        id: 'lesson_01',
        title: 'Repaso rapido',
        type: LessonNodeType.star,
        status: LessonNodeStatus.active,
        position: Offset(146, 18),
      ),
      LessonNode(
        id: 'lesson_02',
        title: 'Vocabulario base',
        type: LessonNodeType.star,
        status: LessonNodeStatus.locked,
        position: Offset(88, 138),
      ),
      LessonNode(
        id: 'lesson_03',
        title: 'Audio y escucha',
        type: LessonNodeType.book,
        status: LessonNodeStatus.locked,
        position: Offset(48, 260),
      ),
      LessonNode(
        id: 'lesson_04',
        title: 'Guia del personaje',
        type: LessonNodeType.boss,
        status: LessonNodeStatus.completed,
        position: Offset(282, 250),
      ),
      LessonNode(
        id: 'lesson_05',
        title: 'Frases utiles',
        type: LessonNodeType.book,
        status: LessonNodeStatus.locked,
        position: Offset(100, 400),
      ),
      LessonNode(
        id: 'lesson_06',
        title: 'Entrenamiento',
        type: LessonNodeType.dumbbell,
        status: LessonNodeStatus.locked,
        position: Offset(146, 530),
      ),
      LessonNode(
        id: 'lesson_07',
        title: 'Dialogos cortos',
        type: LessonNodeType.book,
        status: LessonNodeStatus.locked,
        position: Offset(256, 680),
      ),
      LessonNode(
        id: 'lesson_08',
        title: 'Mini jefe',
        type: LessonNodeType.boss,
        status: LessonNodeStatus.completed,
        position: Offset(42, 830),
      ),
      LessonNode(
        id: 'lesson_09',
        title: 'Pronunciacion',
        type: LessonNodeType.star,
        status: LessonNodeStatus.locked,
        position: Offset(246, 970),
      ),
      LessonNode(
        id: 'lesson_10',
        title: 'Cierre de etapa',
        type: LessonNodeType.boss,
        status: LessonNodeStatus.locked,
        position: Offset(176, 1088),
      ),
    ];
  }

  /// Obtiene los cursos disponibles desde la base de datos en memoria.
  Future<List<Course>> getCourses() async {
    return List<Course>.unmodifiable(MockDatabase.instance.courses);
  }
}