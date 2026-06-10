import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import '../core/mock_database.dart';
import '../models/challenge.dart';
import '../models/dtos/user_dto.dart';
import '../models/more_option.dart';
import '../models/news_article.dart';
import '../models/onboarding_question.dart';
import '../models/ranking_user.dart';
import '../models/user_model.dart';
import '../models/user_profile.dart';
import 'news_repository.dart';

// TODO: Conectar a API Spring Boot real.
/// Repositorio simulado que entrega datos de usuario desde mocks locales.
///
/// Esta implementación permite desacoplar la UI de la fuente real de datos mientras se desarrolla
/// la arquitectura, manteniendo una interfaz preparada para reemplazarse por un backend REST.
class MockUserRepository {
  const MockUserRepository();

  /// ID del usuario con sesión activa en MockDatabase.
  String getCurrentUserId() => MockDatabase.instance.currentUser?.id ?? '';

  /// Activa la sesión de un usuario en MockDatabase.
  void activateSession(String userId) {
    MockDatabase.instance.setActiveUser(userId);
  }

  // ---------- Preguntas de onboarding ----------

  /// Devuelve las preguntas del onboarding.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/onboarding/questions');
  /// return (response.data as List)
  ///     .map((json) => OnboardingQuestion.fromJson(json))
  ///     .toList();
  /// ```
  List<OnboardingQuestion> getOnboardingQuestions() {
    return MockDatabase.instance.onboardingQuestions;
  }

  // ---------- Registro / Autenticación ----------

  /// Registra un usuario nuevo a partir de las respuestas del onboarding y activa la sesion.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.post('/auth/register', data: {
  ///   'onboardingAnswers': onboardingAnswers,
  /// });
  /// final user = User.fromJson(response.data);
  /// return user;
  /// ```
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
      totalXp: 0,
      hearts: 5,
      currentCourseId: course?.id ?? 'course_en',
    );

    return registerUser(user);
  }

  /// Registra un usuario ya construido y activa la sesion en memoria.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.post('/auth/register', data: newUser.toJson());
  /// return User.fromJson(response.data);
  /// ```
  Future<User> registerUser(User newUser) async {
    MockDatabase.instance.upsertUser(newUser);
    MockDatabase.instance.setActiveUser(newUser.id);
    return newUser;
  }

  /// Verifica credenciales contra la base en memoria y activa la sesion si coinciden.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.post('/auth/login', data: {
  ///   'email': email,
  ///   'password': password,
  /// });
  /// final user = User.fromJson(response.data);
  /// return user;
  /// ```
  Future<User?> authenticate(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    for (final user in MockDatabase.instance.users) {
      final bool emailMatches = user.email.trim().toLowerCase() == normalizedEmail;
      final bool passwordMatches = user.passwordHash == normalizedPassword;

      if (emailMatches && passwordMatches) {
        MockDatabase.instance.setActiveUser(user.id);
        return user;
      }
    }

    return null;
  }

  // ---------- Corazones ----------

  /// Devuelve los corazones de un usuario específico.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/users/$uid/hearts');
  /// return response.data as int;
  /// ```
  Future<int> getCurrentHearts([String uid = '']) async {
    final user = uid.isNotEmpty
        ? MockDatabase.instance.findUserById(uid)
        : MockDatabase.instance.currentUser;
    return user?.hearts ?? 0;
  }

  /// Resta un corazón al usuario y persiste el cambio.
  ///
  /// TODO API:
  /// ```dart
  /// await ApiClient.instance.post('/users/$uid/hearts/decrement');
  /// ```
  Future<void> decrementHearts([String uid = '']) async {
    final currentUser = uid.isNotEmpty
        ? MockDatabase.instance.findUserById(uid)
        : MockDatabase.instance.currentUser;
    if (currentUser == null || currentUser.hearts <= 0) return;
    final updatedUser = currentUser.copyWith(hearts: currentUser.hearts - 1);
    MockDatabase.instance.upsertUser(updatedUser);
    MockDatabase.instance.setActiveUser(updatedUser.id);
  }

  // ---------- XP ----------

  /// Suma experiencia al usuario.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.post('/users/$uid/xp', data: {'xp': xp});
  /// return User.fromJson(response.data);
  /// ```
  Future<User?> addXpToCurrentUser(int xp, [String uid = '']) async {
    final User? currentUser = uid.isNotEmpty
        ? MockDatabase.instance.findUserById(uid)
        : MockDatabase.instance.currentUser;
    if (currentUser == null || xp <= 0) {
      return currentUser;
    }

    final User updatedUser = currentUser.copyWith(
      totalXp: currentUser.totalXp + xp,
    );

    MockDatabase.instance.upsertUser(updatedUser);
    MockDatabase.instance.setActiveUser(updatedUser.id);
    return updatedUser;
  }

  // ---------- Progreso ----------

  /// Persiste el progreso completo del usuario a partir de un [UserDTO].
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.put('/users/${userDto.userId}/progress', data: userDto.toJson());
  /// return User.fromJson(response.data);
  /// ```
  Future<User?> saveUserProgress(UserDTO userDto) async {
    final User? existingUser = MockDatabase.instance.findUserById(userDto.userId);
    if (existingUser == null) return null;

    final User updatedUser = existingUser.copyWith(
      name: userDto.name,
      email: userDto.email,
      streakDays: userDto.streakDays,
      totalXp: userDto.totalXp,
      hearts: userDto.hearts,
      gems: userDto.gems,
      currentCourseId: userDto.currentCourseId,
    );

    MockDatabase.instance.upsertUser(updatedUser);
    MockDatabase.instance.setActiveUser(updatedUser.id);
    return updatedUser;
  }

  // ---------- Perfil ----------

  /// Obtiene el perfil del usuario.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/users/$uid/profile');
  /// return UserProfile.fromJson(response.data);
  /// ```
  Future<UserProfile> getUserProfile([String uid = '']) async {
    final currentUser = uid.isNotEmpty
        ? MockDatabase.instance.findUserById(uid)
        : MockDatabase.instance.currentUser;
    final currentCourse = currentUser == null
        ? null
        : MockDatabase.instance.findCourseById(currentUser.currentCourseId);

    if (currentUser == null) {
      return const UserProfile(
        username: 'Invitado',
        avatarUrl: '',
        streakDays: 0,
        gems: 0,
        hearts: 0,
        leagueName: 'Sin curso activo',
        totalXp: 0,
      );
    }

    return UserProfile(
      username: currentUser.name,
      avatarUrl: currentUser.avatarUrl,
      streakDays: currentUser.streakDays,
      gems: currentUser.gems,
      hearts: currentUser.hearts,
      leagueName: currentCourse?.name ?? 'Sin curso activo',
      totalXp: currentUser.totalXp,
    );
  }

  // ---------- Desafíos ----------

  /// Obtiene la lista de desafios del usuario.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/users/$uid/challenges');
  /// return (response.data as List).map((json) => Challenge.fromJson(json)).toList();
  /// ```
  Future<List<Challenge>> getChallenges([String uid = '']) async {
    final database = MockDatabase.instance;
    final currentUser = uid.isNotEmpty
        ? database.findUserById(uid)
        : database.currentUser;
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

  // ---------- Ranking ----------

  /// Obtiene la lista de usuarios del ranking.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/ranking');
  /// return (response.data as List).map((json) => RankingUser.fromJson(json)).toList();
  /// ```
  Future<List<RankingUser>> getRankingUsers([String uid = '']) async {
    final currentUser = uid.isNotEmpty
        ? MockDatabase.instance.findUserById(uid)
        : MockDatabase.instance.currentUser;
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

  // ---------- Datos estáticos ----------

  /// Obtiene la lista de articulos de novedades desde datos falsos.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/news');
  /// return (response.data as List).map((json) => NewsArticle.fromJson(json)).toList();
  /// ```
  Future<List<NewsArticle>> getNewsArticles() async {
    return const MockNewsRepository().getNewsArticles();
  }

  /// Obtiene la lista de opciones del menu "Más".
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/more/options');
  /// return (response.data as List).map((json) => MoreOption.fromJson(json)).toList();
  /// ```
  Future<List<MoreOption>> getMoreOptions() async {
    return MockDatabase.instance.moreOptions;
  }

  // ---------- Métodos privados ----------

  int _calculateTotalXp(User user) {
    final int heartsBonus = user.hearts == -1 ? 500 : user.hearts * 80;
    return user.streakDays * 120 + user.gems ~/ 2 + heartsBonus;
  }

  int _calculateRankingXp(User user) {
    final int heartsBonus = user.hearts == -1 ? 100 : user.hearts * 30;
    return user.streakDays * 40 + user.gems ~/ 8 + heartsBonus;
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
