import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/service_locator.dart';
import '../models/course_model.dart';
import '../models/lesson_activity.dart';
import '../models/lesson_node.dart';

/// Repositorio que entrega el catálogo de cursos, el mapa de lecciones y
/// las actividades generadas por la IA desde el backend Spring Boot.
///
/// El [ApiClient.instance] inyecta automáticamente el token JWT de Firebase
/// en cada petición a través del [_AuthInterceptor].
class MockCourseRepository {
  const MockCourseRepository();

  // ---------- Cursos ----------

  /// Obtiene el catálogo de idiomas disponibles.
  Future<List<Course>> getCourses() async {
    final response = await ApiClient.instance.get('/courses');
    final list = response.data as List;
    return list.map((json) => Course.fromJson(json as Map<String, dynamic>)).toList();
  }

  // ---------- Nodos del mapa ----------

  /// Obtiene los nodos del mapa de lecciones para un curso.
  ///
  /// Cada [LessonNode] regresa sin actividades (lista vacía). El ViewModel
  /// debe cargar las actividades de cada nodo llamando a [getActivitiesForNode].
  Future<List<LessonNode>> getLessonNodes(String courseId) async {
    debugPrint('🗺️ Solicitando mapa de lecciones al backend...');
    final response = await ApiClient.instance.get('/courses/$courseId/nodes');
    debugPrint('📦 DATA RECIBIDA DEL BACKEND: ${response.data}');
    final list = response.data as List;
    final nodos = list.map((json) => LessonNode.fromJson(json as Map<String, dynamic>)).toList();
    debugPrint('✅ Mapa recibido: ${nodos.length} nodos.');

    final int completed = ServiceLocator.completedLessonsCount;
    for (int i = 0; i < nodos.length; i++) {
      if (i < completed) {
        nodos[i] = nodos[i].copyWith(status: NodeStatus.completed);
      } else if (i == completed) {
        nodos[i] = nodos[i].copyWith(status: NodeStatus.active);
      } else {
        nodos[i] = nodos[i].copyWith(status: NodeStatus.locked);
      }
    }

    return nodos;
  }

  // ---------- Actividades de lección ----------

  /// Devuelve las actividades generadas por IA para un nodo específico.
  ///
  /// ⚠️  Este endpoint puede tardar varios segundos porque el backend consulta
  /// un LLM en tiempo real para generar las actividades. El ViewModel debe
  /// manejar correctamente el estado [LessonState.loading] para no bloquear la UI.
  Future<List<LessonActivity>> getActivitiesForNode(String nodeId) async {
    debugPrint('🧠 Solicitando generación dinámica a la IA para el nodo $nodeId (Esto puede tardar unos segundos)...');
    final response = await ApiClient.instance.get('/nodes/$nodeId/activities');
    debugPrint('🚨 RAW JSON DE LA IA: ${response.data}');
    final list = response.data as List;
    final actividades = list.map((json) => LessonActivity.fromJson(json as Map<String, dynamic>)).toList();
    debugPrint('🤖 JSON de IA recibido y parseado: ${actividades.length} actividades.');
    return actividades;
  }

  /// Pool de actividades para el centro de práctica.
  ///
  /// Usa el endpoint dedicado de práctica que genera 10 actividades del mismo tipo.
  Future<List<LessonActivity>> getPracticePool(String type) async {
    debugPrint('🧠 Solicitando actividades de práctica tipo $type al motor de IA...');
    final response = await ApiClient.instance.get('/activities/practice?type=$type');
    final list = response.data as List;
    return list.map((json) => LessonActivity.fromJson(json as Map<String, dynamic>)).toList();
  }
}
