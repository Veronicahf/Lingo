/// Modelo de datos que representa a un usuario dentro de la tabla de ranking.
///
/// Esta entidad separa la informacion del leaderboard de la vista para que las filas se generen
/// desde una fuente tipada, reutilizable y lista para conectarse a la API.
class RankingUser {
  /// Crea un usuario para el ranking.
  const RankingUser({
    required this.name,
    required this.avatarUrl,
    required this.xp,
    required this.isCurrentUser,
  });

  /// Nombre visible del usuario.
  final String name;

  /// URL o ruta del avatar del usuario.
  final String avatarUrl;

  /// Experiencia acumulada del usuario.
  final int xp;

  /// Indica si este usuario es el perfil actual.
  final bool isCurrentUser;
}