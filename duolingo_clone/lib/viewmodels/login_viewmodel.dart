import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../core/mock_database.dart';
import '../repositories/user_repository.dart';

/// ViewModel encargada del inicio de sesion simulado con el backend en memoria.
class LoginViewModel extends BaseViewModel {
  /// Crea la ViewModel de login con repositorio opcional inyectado.
  LoginViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  String _email = '';
  String _password = '';
  bool _showPassword = false;
  User? _authenticatedUser;

  /// Correo capturado en la UI.
  String get email => _email;

  /// Contraseña capturada en la UI.
  String get password => _password;

  /// Indica si el texto de la contraseña debe mostrarse en claro.
  bool get showPassword => _showPassword;

  /// Usuario autenticado despues de un login exitoso, si existe.
  User? get authenticatedUser => _authenticatedUser;

  /// Actualiza el correo y limpia el estado de error si existia.
  void setEmail(String value) {
    _email = value;
    if (errorMessage != null || isSuccess) {
      resetState();
    } else {
      notifyListeners();
    }
  }

  /// Actualiza la contraseña y limpia el estado de error si existia.
  void setPassword(String value) {
    _password = value;
    if (errorMessage != null || isSuccess) {
      resetState();
    } else {
      notifyListeners();
    }
  }

  /// Alterna la visibilidad de la contraseña.
  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  /// Indica si el formulario tiene datos minimos para intentar autenticar.
  bool get isFormValid => _email.trim().isNotEmpty && _password.isNotEmpty;

  /// Ejecuta el login simulado contra el repositorio en memoria.
  Future<bool> login(String email, String password) async {
    setLoading(true);
    _authenticatedUser = null;

    try {
      final user = await _userRepository.authenticate(email, password);

      if (user == null) {
        _authenticatedUser = null;
        setError('Credenciales incorrectas. Verifica tu correo y contraseña.');
        return false;
      }

      _authenticatedUser = user;
      MockDatabase.instance.setActiveUser(user.id);
      setSuccess();
      return true;
    } catch (_) {
      _authenticatedUser = null;
      setError('No se pudo iniciar sesion. Intentalo de nuevo.');
      return false;
    }
  }
}
