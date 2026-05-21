import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/challenge.dart';
import '../repositories/user_repository.dart';

/// ViewModel responsable de cargar y exponer la lista de desafios.
///
/// Esta clase desacopla la vista de la fuente de datos y mantiene el estado de carga mientras
/// obtiene los desafios desde el repositorio mock o, en el futuro, desde la API.
class ChallengesViewModel extends BaseViewModel {
  /// Crea la ViewModel de desafios con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  ChallengesViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  List<Challenge> _challenges = const [];

  /// Desafios disponibles para pintar en la vista.
  List<Challenge> get challenges => _challenges;

  // TODO: Consumir API de Spring Boot cuando el backend de desafios este disponible.
  /// Carga los desafios desde el repositorio y notifica a la UI.
  Future<void> loadChallenges() async {
    setLoading(true);

    try {
      _challenges = await _userRepository.getChallenges();
      setSuccess();
    } catch (error) {
      setError('No se pudieron cargar los desafíos.');
    }
  }
}