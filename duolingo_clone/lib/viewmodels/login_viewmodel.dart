import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../core/api_client.dart';
import '../core/auth_service.dart';
import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';

class LoginViewModel extends BaseViewModel {
  LoginViewModel();

  String _email = '';
  String _password = '';
  bool _showPassword = false;

  String get email => _email;
  String get password => _password;
  bool get showPassword => _showPassword;

  void setEmail(String value) {
    _email = value;
    if (errorMessage != null || isSuccess) {
      resetState();
    } else {
      notifyListeners();
    }
  }

  void setPassword(String value) {
    _password = value;
    if (errorMessage != null || isSuccess) {
      resetState();
    } else {
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  bool get isFormValid => _email.trim().isNotEmpty && _password.isNotEmpty;

  Future<bool> login(String email, String password) async {
    setLoading(true);

    try {
      await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = fb.FirebaseAuth.instance.currentUser;
      if (user == null) {
        setError('No se pudo iniciar sesión.');
        return false;
      }

      try {
        await ApiClient.instance.post('/api/v1/auth/sync', data: {
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? email.split('@').first,
        });
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          final body = e.response?.data;
          if (body is Map && body['message']?.toString().contains('not registered') == true) {
            ServiceLocator.markRegistrationRequired();
          }
        }
      }

      setSuccess();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      setError(_firebaseErrorMessage(e));
      return false;
    } catch (_) {
      setError('No se pudo iniciar sesión. Intentalo de nuevo.');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    setLoading(true);

    try {
      final credential = await AuthService.instance.signInWithGoogle();
      final user = credential.user;
      if (user == null) {
        setError('No se pudo obtener la cuenta de Google.');
        return false;
      }

      try {
        await ApiClient.instance.post('/api/v1/auth/sync', data: {
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? user.email?.split('@').first ?? 'Usuario',
        });
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          final body = e.response?.data;
          if (body is Map && body['message']?.toString().contains('not registered') == true) {
            ServiceLocator.markRegistrationRequired();
          }
        }
      }

      setSuccess();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      setError(_firebaseErrorMessage(e));
      return false;
    } catch (e) {
      setError('No se pudo iniciar sesión con Google: ${e.toString()}');
      return false;
    }
  }

  String _firebaseErrorMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No hay una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}
