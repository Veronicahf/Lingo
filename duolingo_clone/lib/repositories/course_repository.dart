import 'package:flutter/material.dart';

import '../core/mock_database.dart';
import '../models/lesson_activity.dart';
import '../models/lesson_node.dart';

// TODO: Conectar a API Spring Boot real.
/// Repositorio simulado que entrega el mapa de lecciones desde datos locales.
///
/// Cada [LessonNode] incluye su propia lista de [LessonActivity] para que
/// el [LessonViewModel] cargue las actividades del nodo específico al
/// iniciar una lección.
class MockCourseRepository {
  /// Crea un repositorio mock de cursos.
  const MockCourseRepository();

  // ---------- Nodos del mapa ----------

  /// Obtiene una lista de nodos de leccion para el mapa.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/courses/$courseId/nodes');
  /// return (response.data as List).map((json) => LessonNode.fromJson(json)).toList();
  /// ```
  Future<List<LessonNode>> getLessonNodes() async {
    return [
      LessonNode(
        id: 'lesson_01',
        title: 'Repaso rapido',
        type: LessonNodeType.star,
        status: NodeStatus.active,
        position: Offset(146, 18),
        activities: getActivitiesForNode('lesson_01'),
      ),
      LessonNode(
        id: 'lesson_02',
        title: 'Vocabulario base',
        type: LessonNodeType.star,
        status: NodeStatus.locked,
        position: Offset(88, 138),
        activities: getActivitiesForNode('lesson_02'),
      ),
      LessonNode(
        id: 'lesson_03',
        title: 'Audio y escucha',
        type: LessonNodeType.book,
        status: NodeStatus.locked,
        position: Offset(48, 260),
        activities: getActivitiesForNode('lesson_03'),
      ),
      LessonNode(
        id: 'lesson_04',
        title: 'Guia del personaje',
        type: LessonNodeType.boss,
        status: NodeStatus.completed,
        position: Offset(282, 250),
        activities: getActivitiesForNode('lesson_04'),
      ),
      LessonNode(
        id: 'lesson_05',
        title: 'Frases utiles',
        type: LessonNodeType.book,
        status: NodeStatus.locked,
        position: Offset(100, 400),
        activities: getActivitiesForNode('lesson_05'),
      ),
      LessonNode(
        id: 'lesson_06',
        title: 'Entrenamiento',
        type: LessonNodeType.dumbbell,
        status: NodeStatus.locked,
        position: Offset(146, 530),
        activities: getActivitiesForNode('lesson_06'),
      ),
      LessonNode(
        id: 'lesson_07',
        title: 'Dialogos cortos',
        type: LessonNodeType.book,
        status: NodeStatus.locked,
        position: Offset(256, 680),
        activities: getActivitiesForNode('lesson_07'),
      ),
      LessonNode(
        id: 'lesson_08',
        title: 'Mini jefe',
        type: LessonNodeType.boss,
        status: NodeStatus.completed,
        position: Offset(42, 830),
        activities: getActivitiesForNode('lesson_08'),
      ),
      LessonNode(
        id: 'lesson_09',
        title: 'Pronunciacion',
        type: LessonNodeType.star,
        status: NodeStatus.locked,
        position: Offset(246, 970),
        activities: getActivitiesForNode('lesson_09'),
      ),
      LessonNode(
        id: 'lesson_10',
        title: 'Cierre de etapa',
        type: LessonNodeType.boss,
        status: NodeStatus.locked,
        position: Offset(176, 1088),
        activities: getActivitiesForNode('lesson_10'),
      ),
    ];
  }

  // ---------- Actividades de lección ----------

  /// Devuelve las actividades asignadas a un nodo específico del mapa.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/nodes/$nodeId/activities');
  /// return (response.data as List).map((json) => LessonActivity.fromJson(json)).toList();
  /// ```
  List<LessonActivity> getActivitiesForNode(String nodeId) {
    return MockDatabase.instance.getActivitiesForNode(nodeId);
  }

  /// Pool completo de actividades para el centro de práctica.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/activities/practice-pool');
  /// return (response.data as List).map((json) => LessonActivity.fromJson(json)).toList();
  /// ```
  List<LessonActivity> getPracticePool() {
    return MockDatabase.instance.practicePool;
  }

  /// Pool completo de actividades de lección.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/activities/lesson-pool');
  /// return (response.data as List).map((json) => LessonActivity.fromJson(json)).toList();
  /// ```
  List<LessonActivity> getLessonActivities() {
    return MockDatabase.instance.lessonActivities;
  }

  // ---------- Cursos ----------

  /// Obtiene los cursos disponibles.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/courses');
  /// return (response.data as List).map((json) => Course.fromJson(json)).toList();
  /// ```
  Future<List<Course>> getCourses() async {
    return List<Course>.unmodifiable(MockDatabase.instance.courses);
  }
}
