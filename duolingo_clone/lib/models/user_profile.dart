/// Modelo de datos que representa el perfil principal del usuario dentro de la aplicación.
///
/// Este objeto concentra la información estática o proveniente del backend para que la UI
/// y las ViewModels consuman una fuente única, tipada y fácil de mantener.
class UserProfile {
  /// Crea un perfil de usuario con sus métricas de progreso.
  const UserProfile({
    required this.username,
    required this.avatarUrl,
    required this.streakDays,
    required this.gems,
    required this.hearts,
    required this.leagueName,
    required this.totalXp,
    this.currentCourseId,
  });

  /// Nombre visible del usuario.
  final String username;

  /// URL del avatar visible del usuario.
  final String avatarUrl;

  /// Días consecutivos de racha activa.
  final int streakDays;

  /// Monedas o gemas acumuladas por el usuario.
  final int gems;

  /// Corazones disponibles; si vale -1 representa estado infinito.
  final int hearts;

  /// Nombre de la liga actual del usuario.
  final String leagueName;

  /// Experiencia total acumulada por el usuario.
  final int totalXp;

  /// ID del curso activo del usuario.
  final String? currentCourseId;

  /// Construye un [UserProfile] desde un mapa JSON devuelto por la API.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['name'] as String? ?? json['username'] as String? ?? json['displayName'] as String? ?? 'Estudiante',
      avatarUrl: json['avatarUrl'] as String? ?? 'https://ui-avatars.com/api/?name=Estudiante',
      streakDays: json['streakDays'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      hearts: json['hearts'] as int? ?? 5,
      leagueName: json['leagueName'] as String? ?? 'Bronce',
      totalXp: json['totalXp'] as int? ?? 0,
      currentCourseId: json['currentCourseId'] as String?,
    );
  }
}
