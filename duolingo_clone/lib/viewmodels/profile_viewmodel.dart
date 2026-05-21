import '../core/base_viewmodel.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

/// ViewModel encargada de exponer y coordinar el estado de la pantalla de perfil.
///
/// Esta clase conecta la vista con el repositorio, mantiene el perfil cargado en memoria
/// y notifica a la UI cuando cambian los datos o el estado de carga.
class ProfileViewModel extends BaseViewModel {
  /// Crea una ViewModel de perfil con su repositorio inyectado.
  ProfileViewModel(this._userRepository);

  final MockUserRepository _userRepository;

  UserProfile? _profile;

  /// Perfil cargado desde el repositorio o `null` mientras aún no existe respuesta.
  UserProfile? get profile => _profile;

  // TODO: Reemplazar por llamada a la API REST (Spring Boot) para nuestra futura integración.
  /// Carga el perfil del usuario y notifica a la vista cuando la información cambia.
  Future<void> loadProfile() async {
    setLoading(true);

    try {
      _profile = await _userRepository.getUserProfile();
      setSuccess();
    } catch (error) {
      setError('No se pudo cargar el perfil.');
    }
  }
}