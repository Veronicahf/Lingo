import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/base_viewmodel.dart';
import '../../core/service_locator.dart';
import '../../repositories/user_repository.dart';

/// ViewModel que gestiona el flujo de registro obligatorio (Nombre, Correo, Password).
///
/// Firebase Auth es ahora la "Fuente de la Verdad" para la identidad del usuario.
/// El registro en Firebase crea la cuenta de autenticación y, solo después,
/// se notifica al backend Spring Boot para que cree el perfil en PostgreSQL.
/// Esto asegura que el [_AuthInterceptor] de [ApiClient] tenga un token JWT
/// válido de Firebase antes de cualquier llamada a la API.
class RegistrationViewModel extends BaseViewModel {
  RegistrationViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  /// Nombre ingresado por el usuario.
  String get name => _name;

  /// Correo ingresado por el usuario.
  String get email => _email;

  /// Contraseña ingresada por el usuario.
  String get password => _password;

  /// Confirmación de contraseña.
  String get confirmPassword => _confirmPassword;

  /// Error de validación del nombre, si existe.
  String? get nameError => _nameError;

  /// Error de validación del correo, si existe.
  String? get emailError => _emailError;

  /// Error de validación de la contraseña, si existe.
  String? get passwordError => _passwordError;

  /// Indica si el formulario es válido para enviar.
  bool get isValid =>
      _name.trim().isNotEmpty &&
      _email.trim().isNotEmpty &&
      _password.trim().isNotEmpty &&
      _password == _confirmPassword &&
      _nameError == null &&
      _emailError == null &&
      _passwordError == null;

  void setName(String value) {
    _name = value;
    _nameError = value.trim().isEmpty ? 'El nombre es obligatorio' : null;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    final bool isValidEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    _emailError = value.trim().isEmpty
        ? 'El correo es obligatorio'
        : !isValidEmail
            ? 'Correo no válido'
            : null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = value.trim().isEmpty
        ? 'La contraseña es obligatoria'
        : value.trim().length < 6
            ? 'Mínimo 6 caracteres'
            : null;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    if (value.isNotEmpty && value != _password) {
      _passwordError = 'Las contraseñas no coinciden';
    } else if (_password.trim().isNotEmpty && _password.trim().length >= 6) {
      _passwordError = null;
    }
    notifyListeners();
  }

  /// Registra al usuario en Firebase Auth y luego crea su perfil en el backend.
  ///
  /// Flujo:
  /// 1. Firebase Auth crea la cuenta (email+password) — Firebase es la fuente de verdad.
  /// 2. Se actualiza el `displayName` en Firebase con el nombre real.
  /// 3. Se notifica al backend Spring Boot via POST /auth/register para que cree
  ///    el perfil en PostgreSQL. El [_AuthInterceptor] de [ApiClient] inyecta
  ///    automáticamente el token `Authorization: Bearer <token>` de Firebase.
  /// 4. Sin token de Firebase → el backend rechaza la petición con 401.
  Future<bool> submitRegistration() async {
    if (!isValid || isLoading) return false;

    debugPrint('🚀 Iniciando registro de usuario con correo...');
    setLoading(true);

    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password.trim(),
      );
      debugPrint('✅ Usuario creado en Firebase Auth. UID: ${credential.user?.uid}');

      await credential.user?.updateDisplayName(_name.trim());
      await credential.user?.reload();
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      debugPrint('📝 DisplayName en token forzado: ${FirebaseAuth.instance.currentUser?.displayName}');

      debugPrint('📡 Enviando POST /auth/register a Spring Boot...');
      await _userRepository.registerNewUser(onboardingAnswers: ['course_en']);

      ServiceLocator.markRegistrationComplete();
      setSuccess();
      debugPrint('🎉 Registro completo y sesión iniciada localmente.');
      return true;
    } catch (e) {
      debugPrint('🔥 Error Auth raw: $e');

      String message;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            message = 'Este correo ya está registrado.';
            break;
          case 'weak-password':
            message = 'La contraseña es muy débil.';
            break;
          case 'invalid-email':
            message = 'El correo no es válido.';
            break;
          default:
            message = 'Error de autenticación: ${e.message}';
        }
      } else {
        message = 'No se pudo completar el registro. Inténtalo de nuevo.';
      }
      setError(message);
      return false;
    }
  }

  /// Inicia sesión con un proveedor social (Google).
  ///
  /// Firebase Auth maneja el flujo OAuth y, al igual que en [submitRegistration],
  /// el [_AuthInterceptor] usará el token resultante para autenticar la llamada
  /// a [registerNewUser] contra el backend Spring Boot.
  Future<bool> handleSocialLogin() async {
    if (isLoading) return false;

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

      debugPrint('📡 Enviando POST /auth/register a Spring Boot...');
      await _userRepository.registerNewUser(onboardingAnswers: ['course_en']);

      ServiceLocator.markRegistrationComplete();
      setSuccess();
      debugPrint('🎉 Registro social completo y sesión iniciada.');
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

  /// Reinicia el formulario.
  void reset() {
    _name = '';
    _email = '';
    _password = '';
    _confirmPassword = '';
    _nameError = null;
    _emailError = null;
    _passwordError = null;
    resetState();
  }
}
