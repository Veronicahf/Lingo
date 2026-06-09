import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/api_client.dart';
import '../../core/auth_service.dart';
import '../../core/base_viewmodel.dart';
import '../../core/service_locator.dart';

class RegistrationViewModel extends BaseViewModel {
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String? get nameError => _nameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  static bool isRegistrationRequired() {
    return ServiceLocator.completedLessonsCount >= 2 &&
        !ServiceLocator.isRegistered;
  }

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
    final bool isValidEmail =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
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
    } else if (_password.trim().isNotEmpty &&
        _password.trim().length >= 6) {
      _passwordError = null;
    }
    notifyListeners();
  }

  Future<bool> submitRegistration() async {
    if (!isValid || isLoading) return false;

    setLoading(true);
    print('🟡 REGISTRO: Iniciando submitRegistration()');
    notifyListeners();

    try {
      final fb.User? firebaseUser = fb.FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        print('🟡 REGISTRO: No hay sesión Firebase, creando usuario...');
        final credential =
            await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.trim().toLowerCase(),
          password: _password.trim(),
        );
        await credential.user?.updateDisplayName(_name.trim());
        print('✅ REGISTRO: Usuario Firebase creado: ${credential.user?.uid}');
      } else {
        print('🟡 REGISTRO: Ya hay sesión Firebase: ${firebaseUser.uid}');
      }

      final List<String> safeAnswers = ServiceLocator.onboardingAnswers ??
          <String>['Inglés', 'Amigos/familia', 'Estoy empezando', '10 min/día',
              'Para divertirme', 'Practicar leyendo', 'Mañana', 'Sí, empecemos'];

      print('🟡 REGISTRO: Enviando sync a API...');
      print('🟡 REGISTRO: Body -> uid=${fb.FirebaseAuth.instance.currentUser?.uid}, '
          'email=$_email, name=$_name, onboardingAnswers=$safeAnswers');

      await ApiClient.instance.post('/api/v1/users/sync', data: {
        'uid': fb.FirebaseAuth.instance.currentUser?.uid,
        'email': _email.trim().toLowerCase(),
        'name': _name.trim(),
        'onboardingAnswers': safeAnswers,
      });

      print('✅ REGISTRO: Sync API exitoso');

      ServiceLocator.markRegistrationComplete();
      ServiceLocator.profileViewModel.loadUserProfile();
      setLoading(false);
      setSuccess();
      notifyListeners();
      print('✅ REGISTRO: Completado exitosamente');
      return true;
    } on fb.FirebaseAuthException catch (e, stack) {
      print('❌ ERROR FIREBASE AUTH: ${e.message} (code: ${e.code})');
      print('   StackTrace: $stack');
      setLoading(false);
      setError(e.message ?? 'Error de autenticación.');
      notifyListeners();
      return false;
    } catch (e, stack) {
      print('❌ ERROR CRÍTICO EN REGISTRO: $e');
      print('   StackTrace: $stack');
      setLoading(false);
      setError('No se pudo completar el registro. Inténtalo de nuevo.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitGoogleRegistration() async {
    setLoading(true);
    print('🟡 REGISTRO GOOGLE: Iniciando submitGoogleRegistration()');
    notifyListeners();

    try {
      print('🟡 REGISTRO GOOGLE: Llamando AuthService.signInWithGoogle()...');
      await AuthService.instance.signInWithGoogle();
      final fb.User? user = fb.FirebaseAuth.instance.currentUser;
      print('✅ REGISTRO GOOGLE: Usuario Firebase: ${user?.uid} / ${user?.email}');

      if (user == null) {
        setLoading(false);
        setError('No se pudo obtener la cuenta de Google.');
        notifyListeners();
        return false;
      }

      final List<String> safeAnswers = ServiceLocator.onboardingAnswers ??
          <String>['Inglés', 'Amigos/familia', 'Estoy empezando', '10 min/día',
              'Para divertirme', 'Practicar leyendo', 'Mañana', 'Sí, empecemos'];

      print('🟡 REGISTRO GOOGLE: Enviando sync a API...');
      await ApiClient.instance.post('/api/v1/users/sync', data: {
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? user.email?.split('@').first ?? 'Usuario',
        'onboardingAnswers': safeAnswers,
      });

      print('✅ REGISTRO GOOGLE: Sync API exitoso');

      ServiceLocator.markRegistrationComplete();
      ServiceLocator.profileViewModel.loadUserProfile();
      setLoading(false);
      setSuccess();
      notifyListeners();
      print('✅ REGISTRO GOOGLE: Completado exitosamente');
      return true;
    } on fb.FirebaseAuthException catch (e, stack) {
      print('❌ ERROR FIREBASE AUTH GOOGLE: ${e.message} (code: ${e.code})');
      print('   StackTrace: $stack');
      setLoading(false);
      setError(e.message ?? 'Error de autenticación con Google.');
      notifyListeners();
      return false;
    } catch (e, stack) {
      print('❌ ERROR CRÍTICO EN REGISTRO GOOGLE: $e');
      print('   StackTrace: $stack');
      setLoading(false);
      setError('No se pudo completar el registro con Google.');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _name = '';
    _email = '';
    _password = '';
    _confirmPassword = '';
    _nameError = null;
    _emailError = null;
    _passwordError = null;
    resetState();
    notifyListeners();
  }
}
