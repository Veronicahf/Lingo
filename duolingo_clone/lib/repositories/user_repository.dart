import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../core/mock_database.dart';
import '../models/challenge.dart';
import '../models/news_article.dart';
import '../models/more_option.dart';
import '../models/ranking_user.dart';
import '../models/user_profile.dart';
import 'news_repository.dart';

// TODO: Conectar a API Spring Boot real.
/// Repositorio simulado que entrega datos de usuario desde mocks locales.
///
/// Esta implementación permite desacoplar la UI de la fuente real de datos mientras se desarrolla
/// la arquitectura, manteniendo una interfaz preparada para reemplazarse por un backend REST.
class MockUserRepository {
  const MockUserRepository();

  /// Registra un usuario nuevo a partir de las respuestas del onboarding y activa la sesion.
  Future<User> registerNewUser({required List<String> onboardingAnswers}) async {
    final String courseId = _resolveCourseId(onboardingAnswers.isNotEmpty ? onboardingAnswers.first : '');
    final Course? course = MockDatabase.instance.findCourseById(courseId);
    final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final String email = '${courseId}_$userId@lingo.local';
    final String name = 'Aprendiz de ${course?.name ?? 'Inglés'}';

    final user = User(
      id: userId,
      email: email,
      passwordHash: _hashPassword('123456'),
      name: name,
      avatarUrl: 'https://example.com/avatar-onboarding-$courseId.png',
      streakDays: 0,
      gems: 50,
      hearts: 5,
      currentCourseId: course?.id ?? 'course_en',
    );

    MockDatabase.instance.upsertUser(user);
    MockDatabase.instance.setActiveUser(user.id);
    return user;
  }

  /// Verifica credenciales contra la base en memoria y activa la sesion si coinciden.
  Future<User?> authenticate(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final hashedPassword = _hashPassword(password);

    for (final user in MockDatabase.instance.users) {
      if (user.email.toLowerCase() == normalizedEmail && user.passwordHash == hashedPassword) {
        MockDatabase.instance.setActiveUser(user.id);
        return user;
      }
    }

    return null;
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene el perfil del usuario desde datos falsos para simular una respuesta remota.
  Future<UserProfile> getUserProfile() async {
    final currentUser = MockDatabase.instance.currentUser;
    final currentCourse = currentUser == null
        ? null
        : MockDatabase.instance.findCourseById(currentUser.currentCourseId);

    if (currentUser == null) {
      return const UserProfile(
        username: 'Invitado',
        streakDays: 0,
        gems: 0,
        hearts: 0,
        leagueName: 'Sin curso activo',
        totalXp: 0,
      );
    }

    return UserProfile(
      username: currentUser.name,
      streakDays: currentUser.streakDays,
      gems: currentUser.gems,
      hearts: currentUser.hearts,
      leagueName: currentCourse?.name ?? 'Sin curso activo',
      totalXp: _calculateTotalXp(currentUser),
    );
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista de desafios desde datos falsos para simular la respuesta remota.
  Future<List<Challenge>> getChallenges() async {
    final database = MockDatabase.instance;
    final currentUser = database.currentUser;
    final currentCourse = currentUser == null ? null : database.findCourseById(currentUser.currentCourseId);
    final completedPosts = database.newsFeed.where((post) => post.isLikedByMe).length;
    final totalUsers = database.users.length;

    return [
      Challenge(
        eyebrow: 'Desafío entre amigos',
        title: 'Invita a otro compañero',
        currentProgress: totalUsers > 1 ? 1 : 0,
        goal: 1,
        icon: Icons.person_add_alt_1_rounded,
        actionLabel: 'Explorar comunidad',
        actionIcon: Icons.people_alt_rounded,
        chestStyle: ChallengeChestStyle.friend,
      ),
      Challenge(
        eyebrow: 'Desafío del día',
        title: 'Mantén tu racha activa',
        currentProgress: currentUser?.streakDays ?? 0,
        goal: 7,
        icon: Icons.local_fire_department_rounded,
        progressColor: const Color(0xFFFF5CB8),
        chestStyle: ChallengeChestStyle.daily,
      ),
      Challenge(
        eyebrow: 'Tu curso actual',
        title: currentCourse == null ? 'Selecciona un curso' : 'Avanza en ${currentCourse.name}',
        currentProgress: currentUser == null ? 0 : 1,
        goal: 1,
        icon: Icons.menu_book_rounded,
        actionLabel: 'Ver curso',
        actionIcon: Icons.arrow_forward_rounded,
        chestStyle: ChallengeChestStyle.daily,
      ),
      Challenge(
        eyebrow: 'Comunidad',
        title: 'Reacciona a publicaciones recientes',
        currentProgress: completedPosts,
        goal: database.newsFeed.isEmpty ? 1 : database.newsFeed.length,
        icon: Icons.forum_rounded,
        lockedSubtitle: 'Actividad del feed en tiempo real',
        chestStyle: ChallengeChestStyle.locked,
      ),
    ];
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista falsa de usuarios del ranking para simular el leaderboard.
  Future<List<RankingUser>> getRankingUsers() async {
    final currentUser = MockDatabase.instance.currentUser;
    final users = MockDatabase.instance.users
        .map(
          (user) => RankingUser(
            name: user.name,
            avatarUrl: user.avatarUrl,
            xp: _calculateRankingXp(user),
            isCurrentUser: currentUser?.id == user.id,
          ),
        )
        .toList(growable: false);

    users.sort((left, right) => right.xp.compareTo(left.xp));
    return users;
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista de articulos de novedades desde datos falsos.
  Future<List<NewsArticle>> getNewsArticles() async {
    return const MockNewsRepository().getNewsArticles();
  }

  // TODO: Refactorizar para consumir la API REST (Java Spring Boot) usando HTTP.
  /// Obtiene la lista de opciones del menu "Más" desde datos falsos.
  Future<List<MoreOption>> getMoreOptions() async {
    final courses = MockDatabase.instance.courses;
    final options = courses
        .map(
          (course) => MoreOption(
            id: course.id,
            title: course.name,
            subtitle: course.description,
            icon: _iconForCourse(course.id),
            accentColor: _accentColorForCourse(course.id),
            iconBackground: _iconBackgroundForCourse(course.id),
          ),
        )
        .toList(growable: false);

    return [
      ...options,
      MoreOption(
        id: 'community_feed',
        title: 'Comunidad',
        subtitle: '${MockDatabase.instance.newsFeed.length} publicaciones en tu feed',
        icon: Icons.forum_rounded,
        accentColor: const Color(0xFF52BDF7),
        iconBackground: const Color(0xFF1F86C1),
      ),
    ];
  }

  int _calculateTotalXp(User user) {
    final int heartsBonus = user.hearts == -1 ? 500 : user.hearts * 80;
    return user.streakDays * 120 + user.gems ~/ 2 + heartsBonus;
  }

  int _calculateRankingXp(User user) {
    final int heartsBonus = user.hearts == -1 ? 100 : user.hearts * 30;
    return user.streakDays * 40 + user.gems ~/ 8 + heartsBonus;
  }

  IconData _iconForCourse(String courseId) {
    switch (courseId) {
      case 'course_fr':
        return Icons.language_rounded;
      case 'course_it':
        return Icons.restaurant_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _accentColorForCourse(String courseId) {
    switch (courseId) {
      case 'course_fr':
        return const Color(0xFFB87CFF);
      case 'course_it':
        return const Color(0xFFFFC24A);
      default:
        return const Color(0xFF52BDF7);
    }
  }

  Color _iconBackgroundForCourse(String courseId) {
    switch (courseId) {
      case 'course_fr':
        return const Color(0xFF6730A8);
      case 'course_it':
        return const Color(0xFFDA8A00);
      default:
        return const Color(0xFF1F86C1);
    }
  }

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password.trim())).toString();
  }

  /// Traduce la primera respuesta del onboarding al curso disponible en memoria.
  String _resolveCourseId(String selectedOption) {
    switch (selectedOption.trim().toLowerCase()) {
      case 'francés':
        return 'course_fr';
      case 'italiano':
        return 'course_it';
      default:
        return 'course_en';
    }
  }
}
