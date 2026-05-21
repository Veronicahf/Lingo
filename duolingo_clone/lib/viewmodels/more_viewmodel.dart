import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/more_option.dart';
import '../repositories/user_repository.dart';

/// ViewModel responsable de cargar y exponer las opciones de la pantalla "Más".
///
/// Esta clase desacopla la vista de la fuente de datos y mantiene el estado de carga mientras
/// obtiene las opciones desde el repositorio mock o, en el futuro, desde la API.
class MoreViewModel extends BaseViewModel {
  /// Crea la ViewModel de opciones con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  MoreViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  List<MoreOption> _options = const [];

  /// Opciones disponibles para mostrar en la pantalla "Más".
  List<MoreOption> get options => _options;

  // TODO: Consumir API de Spring Boot cuando el backend de opciones este disponible.
  /// Carga las opciones del menu y notifica a la UI cuando terminan de cargar.
  Future<void> loadOptions() async {
    setLoading(true);

    try {
      _options = await _userRepository.getMoreOptions();
      setSuccess();
    } catch (error) {
      setError('No se pudieron cargar las opciones de Más.');
    }
  }
}
