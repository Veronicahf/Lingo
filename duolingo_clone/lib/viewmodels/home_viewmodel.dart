import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/lesson_node.dart';
import '../models/user_profile.dart';
import '../repositories/course_repository.dart';
import '../repositories/user_repository.dart';

/// ViewModel responsable de cargar y exponer el mapa de lecciones del Home.
///
/// Esta clase encapsula la obtencion de nodos de leccion, mantiene el estado de carga y
/// notifica a la vista cuando la lista cambia para que el mapa se pinte desde datos.
class HomeViewModel extends BaseViewModel {
  /// Crea la ViewModel del Home con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  HomeViewModel({MockCourseRepository? courseRepository, MockUserRepository? userRepository})
      : _courseRepository = courseRepository ?? ServiceLocator.courseRepository,
        _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockCourseRepository _courseRepository;
  final MockUserRepository _userRepository;

  List<LessonNode> _lessonNodes = const [];
  UserProfile? _profile;

  /// Lista de nodos que representa el mapa de lecciones.
  List<LessonNode> get lessonNodes => _lessonNodes;

  /// Perfil mock que alimenta la top bar y los modales del Home.
  UserProfile? get profile => _profile;

  /// Nombre del curso actual mostrado en el modal de cursos.
  String get currentCourseName => _profile?.leagueName ?? 'Curso de inglés';

  /// Puntaje actual mostrado en la tarjeta de cursos.
  String get currentCourseScore => _profile == null ? '...' : '${_profile!.totalXp} EXP';

  /// Valor mostrado para el indicador de racha del Home.
  String get streakDaysText => _profile == null ? '...' : '${_profile!.streakDays}';

  /// Valor mostrado para el indicador de gemas del Home.
  String get gemsText => _profile == null ? '...' : '${_profile!.gems}';

  /// Texto mostrado para el estado de energía del Home.
  String get heartsValueText => _profile == null
      ? '...'
      : _profile!.hearts == -1
          ? '∞'
          : '${_profile!.hearts}';

  /// Título del modal de energía.
  String get energyDialogTitle => 'Energía ilimitada';

  /// Subtítulo de apoyo para el modal de energía.
  String get energyDialogSubtitle => 'Sigue aprendiendo sin interrupciones.';

  /// Etiqueta del botón para agregar más cursos.
  String get coursesButtonLabel => 'Cursos';

  /// Etiqueta del botón principal del modal de energía.
  String get energyButtonLabel => 'Continuar';

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

  // TODO: Consumir API de Spring Boot cuando el backend de perfil este disponible.
  /// Carga el perfil del usuario que alimenta la top bar del Home.
  Future<void> loadProfile() async {
    setLoading(true);

    try {
      _profile = await _userRepository.getUserProfile();
      setSuccess();
    } catch (error) {
      setError('No se pudo cargar el perfil del Home.');
    }
  }
}