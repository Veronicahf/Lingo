import 'package:flutter/material.dart';

import '../models/lesson_activity.dart';
import '../models/more_option.dart';
import '../models/onboarding_question.dart';

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
      hearts: hearts ?? this.hearts,
      currentCourseId: currentCourseId ?? this.currentCourseId,
    );
  }
}

/// Representa un curso disponible dentro del catálogo local.
class Course {
  /// Crea un curso con su identificador y metadata visible.
  const Course({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Identificador unico del curso.
  final String id;

  /// Nombre visible del curso.
  final String name;

  /// Descripcion corta del curso.
  final String description;
}

/// Representa una publicacion simple del feed local.
class NewsPost {
  /// Crea una publicacion con su contenido y estado social.
  const NewsPost({
    required this.id,
    required this.authorName,
    required this.content,
    required this.likesCount,
    required this.isLikedByMe,
  });

  /// Identificador unico de la publicacion.
  final String id;

  /// Nombre del autor de la publicacion.
  final String authorName;

  /// Contenido visible de la publicacion.
  final String content;

  /// Cantidad de likes acumulados.
  final int likesCount;

  /// Indica si la publicacion ya fue marcada por el usuario actual.
  final bool isLikedByMe;

  /// Crea una copia de la publicacion con los campos indicados actualizados.
  NewsPost copyWith({
    String? id,
    String? authorName,
    String? content,
    int? likesCount,
    bool? isLikedByMe,
  }) {
    return NewsPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

/// Singleton que simula un backend en memoria para toda la aplicacion.
class MockDatabase {
  /// Crea la instancia compartida de la base de datos en memoria.
  MockDatabase._();

  /// Instancia unica disponible para toda la app.
  static final MockDatabase instance = MockDatabase._();

  static const String _defaultUserId = 'user_01';

  String? _activeUserId = _defaultUserId;

  static final List<User> _users = <User>[
    const User(
      id: 'user_01',
      email: 'lingolearner@example.com',
      passwordHash: 'e10adc3949ba59abbe56e057f20f883e',
      name: 'LingoLearner',
      avatarUrl: 'https://placehold.co/256x256/png?text=Lingo',
      streakDays: 42,
      gems: 1280,
      hearts: -1,
      currentCourseId: 'course_en',
    ),
    const User(
      id: 'user_02',
      email: 'marie@example.com',
      passwordHash: '25f9e794323b453885f5181f1b624d0b',
      name: 'Marie',
      avatarUrl: 'https://placehold.co/256x256/png?text=Marie',
      streakDays: 28,
      gems: 860,
      hearts: 5,
      currentCourseId: 'course_fr',
    ),
    const User(
      id: 'user_03',
      email: 'diego@example.com',
      passwordHash: '5f4dcc3b5aa765d61d8327deb882cf99',
      name: 'Diego',
      avatarUrl: 'https://placehold.co/256x256/png?text=Diego',
      streakDays: 19,
      gems: 640,
      hearts: 3,
      currentCourseId: 'course_en',
    ),
    const User(
      id: 'user_04',
      email: 'adsoft',
      passwordHash: 'adsoft123',
      name: 'Adsoft',
      avatarUrl: 'https://placehold.co/256x256/png?text=Adsoft',
      streakDays: 15,
      gems: 500,
      hearts: 5,
      currentCourseId: 'course_en',
    ),
  ];

  static final List<Course> _courses = <Course>[
    const Course(
      id: 'course_en',
      name: 'Inglés',
      description: 'Domina el inglés con ejercicios breves y progresivos.',
    ),
    const Course(
      id: 'course_fr',
      name: 'Francés',
      description: 'Aprende francés con rutas cortas y repeticion espaciada.',
    ),
    const Course(
      id: 'course_it',
      name: 'Italiano',
      description: 'Explora vocabulario esencial y frases del dia a dia.',
    ),
  ];

  static final List<NewsPost> _newsFeed = <NewsPost>[
    const NewsPost(
      id: 'news_01',
      authorName: 'Marie',
      content: 'Hoy complete una racha de 30 dias seguidos. La constancia si funciona.',
      likesCount: 14,
      isLikedByMe: false,
    ),
    const NewsPost(
      id: 'news_02',
      authorName: 'Diego',
      content: 'Subi de nivel en el curso de ingles y ya entiendo mejor los audios.',
      likesCount: 21,
      isLikedByMe: true,
    ),
    const NewsPost(
      id: 'news_03',
      authorName: 'Camila',
      content: 'Mi primera sesion en frances fue dura, pero ya reconozco saludos basicos.',
      likesCount: 9,
      isLikedByMe: false,
    ),
  ];

  static final List<OnboardingQuestion> _onboardingQuestions = <OnboardingQuestion>[
    const OnboardingQuestion(
      title: '¿Qué te gustaría aprender?',
      animationPath: 'assets/lottie/cat_happy.json',
      options: [
        OnboardingOption(text: 'Inglés', isEnabled: true),
        OnboardingOption(text: 'Francés', isEnabled: false),
        OnboardingOption(text: 'Ajedrez', isEnabled: false),
        OnboardingOption(text: 'Italiano', isEnabled: false),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Cómo supiste de Duolingo?',
      animationPath: 'assets/lottie/Cat_typing.json',
      options: [
        OnboardingOption(text: 'Amigos/familia'),
        OnboardingOption(text: 'Búsqueda en Google'),
        OnboardingOption(text: 'Facebook/Instagram'),
        OnboardingOption(text: 'YouTube'),
        OnboardingOption(text: 'Noticias/artículos/blog'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Cuánto inglés sabes?',
      animationPath: 'assets/lottie/cat_idle.json',
      options: [
        OnboardingOption(text: 'Estoy empezando a aprender inglés'),
        OnboardingOption(text: 'Conozco algunas palabras comunes'),
        OnboardingOption(text: 'Puedo mantener conversaciones simples'),
        OnboardingOption(text: 'Puedo conversar sobre varios temas'),
        OnboardingOption(text: 'Puedo debatir en detalle sobre la mayoría de los temas'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Cuál es tu meta diaria de aprendizaje?',
      animationPath: 'assets/lottie/cat_sleeping.json',
      options: [
        OnboardingOption(text: '3 min/día'),
        OnboardingOption(text: '10 min/día'),
        OnboardingOption(text: '15 min/día'),
        OnboardingOption(text: '30 min/día'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Por qué quieres aprender?',
      animationPath: 'assets/lottie/cat_happy.json',
      options: [
        OnboardingOption(text: 'Para divertirme'),
        OnboardingOption(text: 'Prepararme para viajar'),
        OnboardingOption(text: 'Ejercitar mi mente'),
        OnboardingOption(text: 'Impulsar mis estudios'),
        OnboardingOption(text: 'Impulsar mi carrera profesional'),
        OnboardingOption(text: 'Conectarme con personas'),
        OnboardingOption(text: 'Otros'),
      ],
      allowMultipleSelection: true,
    ),
    const OnboardingQuestion(
      title: '¿Qué formato te ayuda más a aprender?',
      animationPath: 'assets/lottie/Cat_in_a_rocket.json',
      options: [
        OnboardingOption(text: 'Practicar leyendo'),
        OnboardingOption(text: 'Practicar escuchando'),
        OnboardingOption(text: 'Hablar con confianza'),
        OnboardingOption(text: 'Juegos cortos'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Cuándo quieres aprender?',
      animationPath: 'assets/lottie/cat_happy.json',
      options: [
        OnboardingOption(text: 'Mañana'),
        OnboardingOption(text: 'Tarde'),
        OnboardingOption(text: 'Noche'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Listo para comenzar tu primera lección?',
      animationPath: 'assets/lottie/cat_happy.json',
      options: [
        OnboardingOption(text: 'Sí, empecemos'),
        OnboardingOption(text: 'Necesito un poco más'),
      ],
    ),
  ];

  static final List<LessonActivity> _lessonActivities = <LessonActivity>[
    const LessonActivity(
      id: 'lesson_activity_01',
      type: ActivityType.selectTranslation,
      prompt: 'Selecciona la traduccion correcta de la frase.',
      payload: <String, dynamic>{
        'textToTranslate': 'The cat',
        'title': 'Selecciona la traducción correcta',
        'options': <String>['El gato', 'La casa', 'El libro', 'La mesa'],
      },
      correctAnswer: 'El gato',
      aiExplanation: 'La forma correcta es "El gato" porque "the cat" se traduce literalmente como "el gato". El artículo "the" indica que es un sustantivo específico.',
    ),
    const LessonActivity(
      id: 'lesson_activity_02',
      type: ActivityType.matchPairs,
      prompt: 'Empareja cada palabra con su traduccion correcta.',
      payload: <String, String>{
        'casa': 'house',
        'manzana': 'apple',
        'agua': 'water',
      },
      correctAnswer: 'all_matched',
      aiExplanation: 'Emparejar por significado ayuda a no confundir términos cercanos. Una buena estrategia es buscar primero el equivalente más obvio y luego validar los pares restantes.',
    ),
    const LessonActivity(
      id: 'lesson_activity_03',
      type: ActivityType.translateSentence,
      prompt: 'Traduce la oracion completa al ingles.',
      payload: <String, dynamic>{
        'sentence': 'Yo estudio ingles cada dia.',
        'hint': 'I study English every day.',
      },
      correctAnswer: 'I study English every day.',
      aiExplanation: 'La traducción correcta mantiene el sujeto, el verbo en presente y el complemento al final. En inglés, la estructura suele ser sujeto + verbo + objeto o complemento.',
    ),
  ];

  static final List<MoreOption> _moreOptions = <MoreOption>[
    const MoreOption(
      id: 'sounds',
      title: 'Sonidos',
      subtitle: 'Practica vocales y consonantes',
      icon: Icons.graphic_eq_rounded,
      accentColor: Color(0xFF8FE3FF),
      iconBackground: Color(0xFF0F6E8C),
    ),
    const MoreOption(
      id: 'practice_center',
      title: 'Centro de Práctica',
      subtitle: 'Ejercicios guiados',
      icon: Icons.fitness_center_rounded,
      accentColor: Color(0xFFFFD36A),
      iconBackground: Color(0xFF8B5E00),
    ),
    const MoreOption(
      id: 'video_call',
      title: 'Videollamada',
      subtitle: 'Lecciones con personajes',
      icon: Icons.video_call_rounded,
      accentColor: Color(0xFFB8A5FF),
      iconBackground: Color(0xFF5A3CB3),
    ),
  ];

  /// Usuarios disponibles en memoria.
  List<User> get users => _users;

  /// Cursos disponibles en memoria.
  List<Course> get courses => _courses;

  /// Feed de publicaciones disponible en memoria.
  List<NewsPost> get newsFeed => _newsFeed;

  /// Preguntas disponibles para el onboarding.
  List<OnboardingQuestion> get onboardingQuestions => _onboardingQuestions;

  /// Actividades disponibles para una leccion de prueba.
  List<LessonActivity> get lessonActivities => _lessonActivities;

  /// Opciones disponibles para el BottomSheet de la sección Más.
  List<MoreOption> get moreOptions => _moreOptions;

  /// Devuelve el usuario actualmente activo.
  User? get currentUser {
    return _activeUserId == null ? null : _findUserById(_activeUserId!);
  }

  /// Indica si existe una sesion activa en memoria.
  bool get hasActiveSession => _activeUserId != null;

  /// Marca un usuario como sesion activa.
  void setActiveUser(String? userId) {
    _activeUserId = userId;
  }

  /// Limpia la sesion activa y vuelve al estado sin autenticacion.
  void clearActiveUser() {
    _activeUserId = null;
  }

  /// Busca un usuario por su identificador.
  User? findUserById(String id) => _findUserById(id);

  /// Busca un curso por su identificador.
  Course? findCourseById(String id) {
    for (final course in _courses) {
      if (course.id == id) {
        return course;
      }
    }
    return null;
  }

  /// Busca una publicacion por su identificador.
  NewsPost? findNewsPostById(String id) {
    for (final post in _newsFeed) {
      if (post.id == id) {
        return post;
      }
    }
    return null;
  }

  /// Reemplaza un usuario existente o lo agrega si todavia no existe.
  void upsertUser(User user) {
    final index = _users.indexWhere((existingUser) => existingUser.id == user.id);

    if (index == -1) {
      _users.add(user);
      return;
    }

    _users[index] = user;
  }

  /// Reemplaza un curso existente o lo agrega si todavia no existe.
  void upsertCourse(Course course) {
    final index = _courses.indexWhere((existingCourse) => existingCourse.id == course.id);

    if (index == -1) {
      _courses.add(course);
      return;
    }

    _courses[index] = course;
  }

  /// Reemplaza una publicacion existente o la agrega si todavia no existe.
  void upsertNewsPost(NewsPost post) {
    final index = _newsFeed.indexWhere((existingPost) => existingPost.id == post.id);

    if (index == -1) {
      _newsFeed.add(post);
      return;
    }

    _newsFeed[index] = post;
  }

  /// Alterna el like de una publicacion del feed.
  void toggleLikeNewsPost(String postId) {
    final index = _newsFeed.indexWhere((post) => post.id == postId);

    if (index == -1) {
      return;
    }

    final post = _newsFeed[index];
    final bool nextLikedState = !post.isLikedByMe;
    final int nextLikesCount = post.likesCount + (nextLikedState ? 1 : -1);

    _newsFeed[index] = post.copyWith(
      isLikedByMe: nextLikedState,
      likesCount: nextLikesCount < 0 ? 0 : nextLikesCount,
    );
  }

  User? _findUserById(String id) {
    for (final user in _users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }
}