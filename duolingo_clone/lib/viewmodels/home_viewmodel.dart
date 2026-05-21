import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/lesson_node.dart';
import '../repositories/course_repository.dart';

/// ViewModel responsable de cargar y exponer el mapa de lecciones del Home.
///
/// Esta clase encapsula la obtencion de nodos de leccion, mantiene el estado de carga y
/// notifica a la vista cuando la lista cambia para que el mapa se pinte desde datos.
class HomeViewModel extends BaseViewModel {
  /// Crea la ViewModel del Home con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  HomeViewModel({MockCourseRepository? courseRepository})
      : _courseRepository = courseRepository ?? ServiceLocator.courseRepository;

  final MockCourseRepository _courseRepository;

  List<LessonNode> _lessonNodes = const [];

  /// Lista de nodos que representa el mapa de lecciones.
  List<LessonNode> get lessonNodes => _lessonNodes;

  // TODO: Consumir API de Spring Boot cuando el backend del mapa este disponible.
  /// Carga el mapa de lecciones y notifica a la vista una vez disponible.
  Future<void> loadLessonNodes() async {
    setLoading(true);

    try {
      _lessonNodes = await _courseRepository.getLessonNodes();
      setSuccess();
    } catch (error) {
      setError('No se pudo cargar el mapa de lecciones.');
    }
  }
}