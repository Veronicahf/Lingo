import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../repositories/user_repository.dart';

/// ViewModel encargada del inicio de sesión con Firebase Auth.
///
/// Firebase Auth es la "Fuente de la Verdad" para la identidad del usuario.
/// El ViewModel primero autentica al usuario contra Firebase y, si es exitoso,
/// sincroniza con el backend Spring Boot para obtener/perfeccionar el perfil.
/// El [_AuthInterceptor] de [ApiClient] inyecta automáticamente el token JWT
/// en la llamada a [_userRepository.authenticate].
class LoginViewModel extends BaseViewModel {
  LoginViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  String _email = '';
  String _password = '';
  bool _showPassword = false;

  /// Correo capturado en la UI.
  String get email => _email;

  /// Contraseña capturada en la UI.
  String get password => _password;

  /// Indica si el texto de la contraseña debe mostrarse en claro.
  bool get showPassword => _showPassword;

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

  /// Inicia sesión con un proveedor social (Google).
  ///
  /// Firebase Auth maneja el flujo OAuth. Tras autenticar en Firebase,
  /// sincroniza con el backend Spring Boot via POST /auth/login.
  Future<bool> handleSocialLogin() async {
    debugPrint('🚀 Iniciando login social con Google...');
    setLoading(true);

    try {
      if (kIsWeb) {
        debugPrint('🌐 Plataforma web — usando signInWithPopup');
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        debugPrint('📱 Plataforma móvil — usando signInWithProvider');
        await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      }
      debugPrint('✅ Usuario autenticado con Google en Firebase Auth');

      debugPrint('📡 Enviando POST /auth/login a Spring Boot...');
      await _userRepository.authenticate('', '');

      setSuccess();
      debugPrint('🎉 Login social completo y sesión sincronizada.');
      return true;
    } catch (e) {
      debugPrint('🔥 Error Auth raw: $e');

      String message;
      if (e is FirebaseAuthException) {
        message = e.message ?? 'Error al iniciar sesión con Google.';
      } else {
        message = 'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';
      }
      setError(message);
      return false;
    }
  }

  /// Ejecuta el login contra Firebase Auth y sincroniza con el backend.
  ///
  /// Flujo:
  /// 1. Firebase Auth valida credenciales (email+password).
  /// 2. Si Firebase autoriza, se notifica al backend Spring Boot via
  ///    POST /auth/login para sincronizar la sesión en el servidor.
  ///    El [_AuthInterceptor] de [ApiClient] inyecta automáticamente
  ///    el token `Authorization: Bearer <token>` de Firebase.
  /// 3. Sin token de Firebase → el backend rechaza la petición con 401.
  Future<bool> login(String email, String password) async {
    debugPrint('🚀 Iniciando login con correo...');
    setLoading(true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Usuario autenticado en Firebase Auth');

      debugPrint('📡 Enviando POST /auth/login a Spring Boot...');
      await _userRepository.authenticate(email, password);

      setSuccess();
      debugPrint('🎉 Login completo y sesión sincronizada.');
      return true;
    } catch (e) {
      debugPrint('🔥 Error Auth raw: $e');

      String message;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            message = 'Usuario no encontrado.';
            break;
          case 'wrong-password':
            message = 'Contraseña incorrecta.';
            break;
          case 'invalid-credential':
            message = 'Credenciales inválidas. Verifica tu correo y contraseña.';
            break;
          case 'invalid-email':
            message = 'El correo no tiene un formato válido.';
            break;
          case 'user-disabled':
            message = 'Esta cuenta ha sido deshabilitada.';
            break;
          case 'too-many-requests':
            message = 'Demasiados intentos. Intenta más tarde.';
            break;
          default:
            message = e.message ?? 'Error de autenticación.';
        }
      } else {
        message = 'No se pudo iniciar sesión. Inténtalo de nuevo.';
      }
      setError(message);
      return false;
    }
  }
}
