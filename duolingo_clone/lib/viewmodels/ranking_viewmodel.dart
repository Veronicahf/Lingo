import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/ranking_user.dart';
import '../repositories/user_repository.dart';

/// ViewModel responsable de cargar y exponer la tabla de ranking.
///
/// Esta clase mantiene la lista de usuarios del leaderboard desacoplada de la vista y prepara
/// la capa de presentacion para reemplazar mocks por llamadas de red en el futuro.
class RankingViewModel extends BaseViewModel {
  /// Crea la ViewModel del ranking con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  RankingViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  List<RankingUser> _rankingUsers = const [];

  /// Usuarios que conforman la tabla de ranking.
  List<RankingUser> get rankingUsers => _rankingUsers;

  /// Indice del usuario actual dentro de la lista de ranking.
  int get currentUserIndex => _rankingUsers.indexWhere((user) => user.isCurrentUser);

  // TODO: Consumir API de Spring Boot cuando el backend del ranking este disponible.
  /// Carga el ranking y notifica a la vista una vez que la informacion esta lista.
  Future<void> loadRankingUsers() async {
    setLoading(true);

    try {
      _rankingUsers = await _userRepository.getRankingUsers();
      setSuccess();
    } catch (error) {
      setError('No se pudo cargar el ranking.');
    }
  }
}