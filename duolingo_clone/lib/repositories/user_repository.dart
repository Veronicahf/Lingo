import 'package:flutter/material.dart';

import '../models/challenge.dart';
import '../models/news_article.dart';
import '../models/more_option.dart';
import '../models/ranking_user.dart';
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

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista de desafios desde datos falsos para simular la respuesta remota.
  Future<List<Challenge>> getChallenges() async {
    return const [
      Challenge(
        eyebrow: 'Desafío entre amigos',
        title: 'Sigue a tu primer amigo',
        currentProgress: 0,
        goal: 1,
        icon: Icons.person_add_alt_1_rounded,
        actionLabel: 'Encuentra a tus amigos',
        actionIcon: Icons.person_add_alt_1_rounded,
        chestStyle: ChallengeChestStyle.friend,
      ),
      Challenge(
        eyebrow: 'Desafío del día',
        title: 'Empieza una racha',
        currentProgress: 1,
        goal: 1,
        icon: Icons.local_fire_department_rounded,
        progressColor: Color(0xFFFF5CB8),
        chestStyle: ChallengeChestStyle.daily,
      ),
      Challenge(
        eyebrow: 'A continuación',
        title: 'Se revelará en 6 días',
        currentProgress: 0,
        goal: 1,
        icon: Icons.lock_rounded,
        chestStyle: ChallengeChestStyle.locked,
        lockedSubtitle: 'Se revelará en 6 días',
        isLocked: true,
      ),
      Challenge(
        eyebrow: 'A continuación',
        title: 'Se revelará en 6 días',
        currentProgress: 0,
        goal: 1,
        icon: Icons.lock_rounded,
        chestStyle: ChallengeChestStyle.locked,
        lockedSubtitle: 'Se revelará en 6 días',
        isLocked: true,
      ),
    ];
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista falsa de usuarios del ranking para simular el leaderboard.
  Future<List<RankingUser>> getRankingUsers() async {
    return const [
      RankingUser(name: 'Alicia', avatarUrl: 'https://example.com/avatar-alicia.png', xp: 214, isCurrentUser: false),
      RankingUser(name: 'Bruno', avatarUrl: 'https://example.com/avatar-bruno.png', xp: 208, isCurrentUser: false),
      RankingUser(name: 'Camila', avatarUrl: 'https://example.com/avatar-camila.png', xp: 203, isCurrentUser: false),
      RankingUser(name: 'veronica', avatarUrl: 'https://example.com/avatar-veronica.png', xp: 198, isCurrentUser: true),
      RankingUser(name: 'Daniel', avatarUrl: 'https://example.com/avatar-daniel.png', xp: 191, isCurrentUser: false),
      RankingUser(name: 'Elena', avatarUrl: 'https://example.com/avatar-elena.png', xp: 185, isCurrentUser: false),
      RankingUser(name: 'Fabio', avatarUrl: 'https://example.com/avatar-fabio.png', xp: 180, isCurrentUser: false),
      RankingUser(name: 'Gina', avatarUrl: 'https://example.com/avatar-gina.png', xp: 172, isCurrentUser: false),
    ];
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista de articulos de novedades desde datos falsos.
  Future<List<NewsArticle>> getNewsArticles() async {
    return const [
      NewsArticle(
        id: 'news_01',
        title: '¡Celebra tus logros con tus amigos!',
        description: 'Comparte tu progreso y anima a tu circulo a seguir aprendiendo contigo.',
        buttonText: 'AGREGA AMIGOS',
        backgroundColor: 0xFF24A0E0,
        iconData: Icons.celebration_rounded,
      ),
      NewsArticle(
        id: 'news_02',
        title: 'Tu racha esta imparable',
        description: 'Mantener una racha fuerte te ayuda a consolidar habitos de estudio diarios.',
        buttonText: 'VER MI RACHA',
        backgroundColor: 0xFF26333B,
        iconData: Icons.local_fire_department_rounded,
      ),
      NewsArticle(
        id: 'news_03',
        title: 'He was awarded a medal for his bravery!',
        description: '¡Recibió una medalla por su valentía!',
        buttonText: 'VER HISTORIA',
        backgroundColor: 0xFF9FE33A,
        iconData: Icons.flutter_dash_rounded,
      ),
    ];
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista de opciones del menu "Más" desde datos falsos.
  Future<List<MoreOption>> getMoreOptions() async {
    return const [
      MoreOption(
        id: 'sounds',
        title: 'Sonidos',
        subtitle: 'Practica vocales y consonantes',
        icon: Icons.graphic_eq_rounded,
        accentColor: Color(0xFF52BDF7),
        iconBackground: Color(0xFF1F86C1),
      ),
      MoreOption(
        id: 'practice_center',
        title: 'Centro de Práctica',
        subtitle: 'Ejercicios guiados y tarjetas',
        icon: Icons.fitness_center_rounded,
        accentColor: Color(0xFFFFC24A),
        iconBackground: Color(0xFFDA8A00),
      ),
      MoreOption(
        id: 'video_call',
        title: 'Videollamada',
        subtitle: 'Lecciones con personajes',
        icon: Icons.video_call_rounded,
        accentColor: Color(0xFFB87CFF),
        iconBackground: Color(0xFF6730A8),
      ),
    ];
  }
}
