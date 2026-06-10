import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

/// ViewModel encargada de exponer y coordinar el estado de la pantalla de perfil.
///
/// Esta clase conecta la vista con el repositorio, mantiene el perfil cargado en memoria
/// y notifica a la UI cuando cambian los datos o el estado de carga.
class ProfileViewModel extends BaseViewModel {
  /// Crea una ViewModel de perfil con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se utiliza la instancia registrada en [ServiceLocator].
  ProfileViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  UserProfile? _profile;

  /// Perfil cargado desde el repositorio o `null` mientras aún no existe respuesta.
  UserProfile? get profile => _profile;

  /// Carga el perfil del usuario y notifica a la vista cuando la información cambia.
  Future<void> loadProfile() async {
    setLoading(true);

    try {
      final profile = await _userRepository.getUserProfile();
      debugPrint('👤 Perfil recibido en ViewModel: ${profile.username}, ${profile.totalXp} XP, ${profile.streakDays} días, ${profile.gems} gemas, ${profile.hearts} corazones, liga: ${profile.leagueName}');
      _profile = profile;
      notifyListeners();
      setSuccess();
    } catch (error) {
      debugPrint('❌ Error al cargar perfil: $error');
      setError('No se pudo cargar el perfil.');
    }
  }

  /// Cierra la sesión del usuario en Firebase Auth y limpia el estado local.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _profile = null;
    resetState();
  }
}