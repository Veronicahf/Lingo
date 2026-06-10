/// Representa un usuario persistido en la base de datos en memoria.
class User {
  /// Crea un usuario con credenciales y progreso simulados.
  const User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.avatarUrl,
    required this.streakDays,
    required this.gems,
    required this.totalXp,
    required this.hearts,
    required this.currentCourseId,
  });

  /// Identificador unico del usuario.
  final String id;

  /// Correo electronico del usuario.
  final String email;

  /// Hash simulado de la contraseña.
  final String passwordHash;

  /// Nombre visible del usuario.
  final String name;

  /// URL del avatar del usuario.
  final String avatarUrl;

  /// Dias consecutivos de racha.
  final int streakDays;

  /// Gemas acumuladas por el usuario.
  final int gems;

  /// Experiencia total acumulada por el usuario.
  final int totalXp;

  /// Corazones disponibles; -1 representa energia infinita.
  final int hearts;

  /// Identificador del curso que el usuario tiene activo.
  final String currentCourseId;

  /// Crea una copia del usuario con los campos indicados actualizados.
  User copyWith({
    String? id,
    String? email,
    String? passwordHash,
    String? name,
    String? avatarUrl,
    int? streakDays,
    int? gems,
    int? totalXp,
    int? hearts,
    String? currentCourseId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      streakDays: streakDays ?? this.streakDays,
      gems: gems ?? this.gems,
      totalXp: totalXp ?? this.totalXp,
      hearts: hearts ?? this.hearts,
      currentCourseId: currentCourseId ?? this.currentCourseId,
    );
  }
}
