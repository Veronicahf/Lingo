import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../core/api_client.dart';
import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

class ProfileViewModel extends BaseViewModel {
  ProfileViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  UserProfile? _profile;

  UserProfile? get profile => _profile;

  bool _isLoggedIn() {
    try {
      return fb.FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadProfile() async {
    setLoading(true);

    if (_isLoggedIn()) {
      await loadUserProfile();
      return;
    }

    try {
      _profile = await _userRepository.getUserProfile();
      setSuccess();
    } catch (_) {
      setError('No se pudo cargar el perfil.');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final response = await ApiClient.instance.get('/api/v1/users/profile');
      final data = response.data as Map<String, dynamic>;

      _profile = UserProfile(
        username: (data['name'] as String?) ?? 'Usuario',
        avatarUrl: (data['avatarUrl'] as String?) ?? '',
        streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
        gems: (data['gems'] as num?)?.toInt() ?? 0,
        hearts: (data['hearts'] as num?)?.toInt() ?? 5,
        leagueName: (data['leagueName'] as String?) ?? 'Sin curso activo',
        totalXp: (data['totalXp'] as num?)?.toInt() ?? 0,
      );
      setSuccess();
    } catch (_) {
      try {
        _profile = await _userRepository.getUserProfile();
        setSuccess();
      } catch (_) {
        setError('No se pudo cargar el perfil.');
      }
    }
  }
}
