import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/base_viewmodel.dart';
import '../../core/mock_database.dart';
import '../../core/service_locator.dart';
import '../../models/dtos/user_dto.dart';
import '../../repositories/user_repository.dart';

/// ViewModel que gestiona el flujo de registro obligatorio (Nombre, Correo, Password).
///
/// Se activa al completar la lección 2 o al intentar acceder a Ranking/Perfil
/// sin haber finalizado el registro. Al completarse, persiste el [User] completo
/// en MockDatabase y activa la sesión.
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

  /// Completa el registro creando el usuario, activando la sesión y
  /// persistiendo el progreso inicial en MockDatabase.
  Future<User?> submitRegistration() async {
    if (!isValid || isLoading) return null;

    setLoading(true);

    try {
      final String courseId = 'course_en';
      final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final User newUser = User(
        id: userId,
        email: _email.trim().toLowerCase(),
        passwordHash: md5.convert(utf8.encode(_password.trim())).toString(),
        name: _name.trim(),
        avatarUrl: 'https://placehold.co/256x256/png?text=${Uri.encodeComponent(_name.trim())}',
        streakDays: 0,
        gems: 50,
        totalXp: 0,
        hearts: 5,
        currentCourseId: courseId,
      );

      final User registeredUser = await _userRepository.registerUser(newUser);

      // Persiste progreso inicial a través del DTO
      final UserDTO initialProgress = UserDTO(
        userId: registeredUser.id,
        name: registeredUser.name,
        email: registeredUser.email,
        password: _password.trim(),
        streakDays: 0,
        totalXp: 0,
        level: 1,
        hearts: 5,
        gems: 50,
        currentCourseId: courseId,
        avatarUrl: registeredUser.avatarUrl,
      );
      await _userRepository.saveUserProgress(initialProgress);

      ServiceLocator.markRegistrationComplete();
      setSuccess();
      return registeredUser;
    } catch (_) {
      setError('No se pudo completar el registro. Inténtalo de nuevo.');
      return null;
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
