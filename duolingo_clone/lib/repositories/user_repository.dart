import '../models/user_profile.dart';

// TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
/// Repositorio simulado que entrega datos de usuario desde mocks locales.
///
/// Esta implementación permite desacoplar la UI de la fuente real de datos mientras se desarrolla
/// la arquitectura, manteniendo una interfaz preparada para reemplazarse por un backend REST.
class MockUserRepository {
  const MockUserRepository();

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene el perfil del usuario desde datos falsos para simular una respuesta remota.
  Future<UserProfile> getUserProfile() async {
    return const UserProfile(
      username: 'LingoLearner',
      streakDays: 42,
      gems: 1280,
      hearts: -1,
      leagueName: 'Liga Diamante',
      totalXp: 18450,
    );
  }
}
