import '../repositories/course_repository.dart';
import '../repositories/user_repository.dart';

/// Registro estatico de dependencias base para la aplicacion.
///
/// Esta implementacion simple de Service Locator centraliza la creacion y acceso
/// a dependencias compartidas para evitar instancias manuales en la capa de vistas.
class ServiceLocator {
  ServiceLocator._();

  static late MockUserRepository _userRepository;
  static late MockCourseRepository _courseRepository;

  /// Inicializa las dependencias globales requeridas por la aplicacion.
  static void init() {
    _userRepository = const MockUserRepository();
    _courseRepository = const MockCourseRepository();
  }

  /// Repositorio de usuario disponible para ViewModels y casos de uso.
  static MockUserRepository get userRepository => _userRepository;

  /// Repositorio de cursos disponible para el mapa de lecciones.
  static MockCourseRepository get courseRepository => _courseRepository;
}