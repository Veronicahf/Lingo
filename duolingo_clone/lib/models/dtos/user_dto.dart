/// DTO que encapsula los datos de progreso del usuario para persistencia.
///
/// Agrupa racha, nivel, XP y configuración en un solo objeto JSON antes de
/// enviarlo al repositorio, asegurando un contrato de comunicación uniforme.
class UserDTO {
  const UserDTO({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.streakDays,
    required this.totalXp,
    required this.level,
    required this.hearts,
    required this.gems,
    required this.currentCourseId,
    this.avatarUrl,
  });

  /// Identificador único del usuario.
  final String userId;

  /// Nombre visible del usuario.
  final String name;

  /// Correo electrónico del usuario.
  final String email;

  /// Contraseña en texto plano (se hashea antes de persistir).
  final String password;

  /// Días consecutivos de racha.
  final int streakDays;

  /// Experiencia total acumulada.
  final int totalXp;

  /// Nivel calculado del usuario.
  final int level;

  /// Corazones disponibles (-1 = infinito).
  final int hearts;

  /// Gemas acumuladas.
  final int gems;

  /// Curso activo del usuario.
  final String currentCourseId;

  /// URL del avatar.
  final String? avatarUrl;

  /// Construye un [UserDTO] desde un mapa JSON.
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      streakDays: json['streakDays'] as int,
      totalXp: json['totalXp'] as int,
      level: json['level'] as int,
      hearts: json['hearts'] as int,
      gems: json['gems'] as int,
      currentCourseId: json['currentCourseId'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Serializa este DTO a un mapa JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'email': email,
      'password': password,
      'streakDays': streakDays,
      'totalXp': totalXp,
      'level': level,
      'hearts': hearts,
      'gems': gems,
      'currentCourseId': currentCourseId,
      'avatarUrl': avatarUrl,
    };
  }

  /// Crea una copia con los campos actualizados.
  UserDTO copyWith({
    String? userId,
    String? name,
    String? email,
    String? password,
    int? streakDays,
    int? totalXp,
    int? level,
    int? hearts,
    int? gems,
    String? currentCourseId,
    String? avatarUrl,
  }) {
    return UserDTO(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      streakDays: streakDays ?? this.streakDays,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      hearts: hearts ?? this.hearts,
      gems: gems ?? this.gems,
      currentCourseId: currentCourseId ?? this.currentCourseId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
