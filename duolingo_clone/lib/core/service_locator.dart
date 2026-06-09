import 'audio_service.dart';
import '../repositories/course_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/shop_repository.dart';
import '../repositories/user_repository.dart';

/// Registro estatico de dependencias base para la aplicacion.
///
/// Esta implementacion simple de Service Locator centraliza la creacion y acceso
/// a dependencias compartidas para evitar instancias manuales en la capa de vistas.
class ServiceLocator {
  ServiceLocator._();

  static late AudioService _audioService;
  static late MockUserRepository _userRepository;
  static late MockCourseRepository _courseRepository;
  static late MockNewsRepository _newsRepository;
  static late MockShopRepository _shopRepository;

  static bool _registrationRequired = false;
  static int _completedLessonsCount = 0;
  static int _lastCompletedLessonIndex = -1;

  /// Indica si el usuario debe completar el registro antes de continuar.
  static bool get registrationRequired => _registrationRequired;

  /// Número de lecciones completadas acumuladas (persistente entre sesiones).
  static int get completedLessonsCount => _completedLessonsCount;

  /// Marca que el onboarding recolectó datos pero falta el registro.
  static void markRegistrationRequired() {
    _registrationRequired = true;
  }

  /// Marca que el registro se completó exitosamente.
  static void markRegistrationComplete() {
    _registrationRequired = false;
  }

  /// Incrementa el contador acumulado de lecciones completadas.
  static void incrementCompletedLessons() {
    _completedLessonsCount++;
  }

  /// Índice del último nodo completado en el mapa (para scroll persistente).
  static int get lastCompletedLessonIndex => _lastCompletedLessonIndex;

  /// Guarda el índice del nodo completado para restaurar scroll al regresar.
  static void setLastCompletedLessonIndex(int index) {
    _lastCompletedLessonIndex = index;
  }

  /// Inicializa las dependencias globales requeridas por la aplicacion.
  static void init() {
    _audioService = AudioService.instance;
    _userRepository = const MockUserRepository();
    _courseRepository = const MockCourseRepository();
    _newsRepository = const MockNewsRepository();
    _shopRepository = const MockShopRepository();
  }

  /// Servicio de audio compartido para actividades con TTS.
  static AudioService get audioService => _audioService;

  /// Repositorio de usuario disponible para ViewModels y casos de uso.
  static MockUserRepository get userRepository => _userRepository;

  /// Repositorio de cursos disponible para el mapa de lecciones.
  static MockCourseRepository get courseRepository => _courseRepository;

  /// Repositorio de novedades disponible para el feed social.
  static MockNewsRepository get newsRepository => _newsRepository;

  /// Repositorio de tienda disponible para la pantalla de Shop.
  static MockShopRepository get shopRepository => _shopRepository;
}