import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../models/lesson_activity.dart';
import '../models/more_option.dart';
import '../models/onboarding_question.dart';
import '../models/user_model.dart';

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
      totalXp: 6180,
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
      totalXp: 4190,
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
      totalXp: 2840,
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
      totalXp: 2450,
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
      animationEmotion: 'happy',
      options: [
        OnboardingOption(text: 'Inglés', isEnabled: true),
        OnboardingOption(text: 'Francés', isEnabled: false),
        OnboardingOption(text: 'Ajedrez', isEnabled: false),
        OnboardingOption(text: 'Italiano', isEnabled: false),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Cómo supiste de Duolingo?',
      animationEmotion: 'typing',
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
      animationEmotion: 'idle',
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
      animationEmotion: 'sleeping',
      options: [
        OnboardingOption(text: '3 min/día'),
        OnboardingOption(text: '10 min/día'),
        OnboardingOption(text: '15 min/día'),
        OnboardingOption(text: '30 min/día'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Por qué quieres aprender?',
      animationEmotion: 'happy',
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
      animationEmotion: 'rocket',
      options: [
        OnboardingOption(text: 'Practicar leyendo'),
        OnboardingOption(text: 'Practicar escuchando'),
        OnboardingOption(text: 'Hablar con confianza'),
        OnboardingOption(text: 'Juegos cortos'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Cuándo quieres aprender?',
      animationEmotion: 'happy',
      options: [
        OnboardingOption(text: 'Mañana'),
        OnboardingOption(text: 'Tarde'),
        OnboardingOption(text: 'Noche'),
      ],
    ),
    const OnboardingQuestion(
      title: '¿Listo para comenzar tu primera lección?',
      animationEmotion: 'happy',
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
      mascotEmotion: 'happy',
    ),
    const LessonActivity(
      id: 'lesson_activity_02',
      type: ActivityType.selectTranslation,
      prompt: 'Selecciona la traduccion correcta de "house".',
      payload: <String, dynamic>{
        'textToTranslate': 'house',
        'title': 'Selecciona la traducción correcta',
        'options': <String>['casa', 'mesa', 'agua', 'libro'],
      },
      correctAnswer: 'casa',
      aiExplanation: '"House" se traduce como "casa" en español. Es un sustantivo femenino que se usa para referirse a un lugar de residencia.',
      mascotEmotion: 'typing',
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
      mascotEmotion: 'typing',
    ),
    const LessonActivity(
      id: 'lesson_activity_04',
      type: ActivityType.speaking,
      prompt: 'Repite la frase en voz alta.',
      payload: <String, dynamic>{
        'title': 'Practica la pronunciación',
        'sentence': 'We drink water every day.',
        'audioText': 'We drink water every day.',
      },
      correctAnswer: 'speaking_completed',
      aiExplanation: 'Escuchar y repetir ayuda a fijar ritmo, acentuación y memoria auditiva.',
      mascotEmotion: 'speaking',
    ),
    const LessonActivity(
      id: 'lesson_activity_05',
      type: ActivityType.listenSelect,
      prompt: 'Escucha y selecciona la traducción correcta.',
      payload: <String, dynamic>{
        'title': 'Escucha la frase y elige la opción correcta',
        'subtitle': 'She drinks water.',
        'audioText': 'She drinks water.',
        'options': <String>[
          'Ella bebe agua',
          'Él bebe agua',
          'Ella come pan',
          'Nosotros bebemos agua',
        ],
      },
      correctAnswer: 'Ella bebe agua',
      aiExplanation: 'La frase usa tercera persona singular en presente simple, por eso la traducción correcta es "Ella bebe agua".',
      mascotEmotion: 'idle',
    ),
  ];

  static final List<LessonActivity> _practicePool = <LessonActivity>[
    const LessonActivity(
      id: 'practice_01',
      type: ActivityType.speaking,
      prompt: 'Repite la frase en voz alta.',
      payload: <String, dynamic>{
        'title': 'Practica la pronunciación',
        'sentence': 'I like to read books.',
        'audioText': 'I like to read books.',
      },
      correctAnswer: 'speaking_completed',
      aiExplanation: 'Repetir en voz alta mejora la retención y la fluidez oral.',
      mascotEmotion: 'speaking',
      category: 'speaking',
    ),
    const LessonActivity(
      id: 'practice_02',
      type: ActivityType.speaking,
      prompt: 'Repite lo que escuchas.',
      payload: <String, dynamic>{
        'title': 'Repite la frase',
        'sentence': 'She goes to school every morning.',
        'audioText': 'She goes to school every morning.',
      },
      correctAnswer: 'speaking_completed',
      aiExplanation: 'La repetición ayuda a fijar patrones gramaticales y de entonación.',
      mascotEmotion: 'speaking',
      category: 'speaking',
    ),
    const LessonActivity(
      id: 'practice_03',
      type: ActivityType.listenSelect,
      prompt: 'Escucha y elige la opción correcta.',
      payload: <String, dynamic>{
        'title': 'Comprensión auditiva',
        'subtitle': 'They play soccer on weekends.',
        'audioText': 'They play soccer on weekends.',
        'options': <String>[
          'Ellos juegan fútbol los fines de semana',
          'Ellos juegan tenis los lunes',
          'Nosotros jugamos fútbol',
          'Ellos corren los fines de semana',
        ],
      },
      correctAnswer: 'Ellos juegan fútbol los fines de semana',
      aiExplanation: 'La frase usa el presente simple para expresar rutinas. "They play soccer on weekends" se traduce como una acción habitual.',
      mascotEmotion: 'idle',
      category: 'listening',
    ),
    const LessonActivity(
      id: 'practice_04',
      type: ActivityType.listenSelect,
      prompt: 'Escucha y selecciona la respuesta correcta.',
      payload: <String, dynamic>{
        'title': 'Escucha con atención',
        'subtitle': 'The cat is sleeping on the sofa.',
        'audioText': 'The cat is sleeping on the sofa.',
        'options': <String>[
          'El gato está durmiendo en el sofá',
          'El perro está corriendo en el parque',
          'El gato está comiendo en la cocina',
          'El pájaro está cantando en el árbol',
        ],
      },
      correctAnswer: 'El gato está durmiendo en el sofá',
      aiExplanation: 'El verbo "is sleeping" está en presente continuo, indicando una acción en progreso.',
      mascotEmotion: 'idle',
      category: 'listening',
    ),
    const LessonActivity(
      id: 'practice_05',
      type: ActivityType.fillBlank,
      prompt: 'Completa la oración con la palabra correcta.',
      payload: <String, dynamic>{
        'title': 'Completa la frase',
        'sentence': 'She ___ to music every day.',
        'options': <String>['listens', 'listen', 'listening', 'listened'],
        'correctOption': 'listens',
      },
      correctAnswer: 'listens',
      aiExplanation: 'En presente simple, la tercera persona singular lleva una "s" al final del verbo: "listens".',
      mascotEmotion: 'typing',
      category: 'grammar',
    ),
    const LessonActivity(
      id: 'practice_06',
      type: ActivityType.fillBlank,
      prompt: 'Elige la opción correcta para completar la oración.',
      payload: <String, dynamic>{
        'title': 'Gramática rápida',
        'sentence': 'They ___ to the park yesterday.',
        'options': <String>['went', 'go', 'goes', 'going'],
        'correctOption': 'went',
      },
      correctAnswer: 'went',
      aiExplanation: '"Yesterday" indica pasado, por lo que usamos el pasado simple "went".',
      mascotEmotion: 'typing',
      category: 'grammar',
    ),
    const LessonActivity(
      id: 'practice_07',
      type: ActivityType.selectTranslation,
      prompt: 'Selecciona la traducción correcta.',
      payload: <String, dynamic>{
        'textToTranslate': 'The children are playing outside',
        'title': 'Traduce la frase',
        'options': <String>['Los niños están jugando afuera', 'Los niños juegan afuera', 'Los niños jugaron afuera', 'Los niños jugarán afuera'],
      },
      correctAnswer: 'Los niños están jugando afuera',
      aiExplanation: '"Are playing" es presente continuo, indicando una acción que ocurre ahora.',
      mascotEmotion: 'happy',
      category: 'translation',
    ),
    const LessonActivity(
      id: 'practice_08',
      type: ActivityType.translateSentence,
      prompt: 'Traduce la oración al inglés.',
      payload: <String, dynamic>{
        'sentence': 'Nosotros vivimos en una casa grande.',
        'hint': 'We live in a big house.',
      },
      correctAnswer: 'We live in a big house.',
      aiExplanation: 'La estructura mantiene sujeto + verbo + complemento. "Vivimos" es "we live" en presente simple.',
      mascotEmotion: 'typing',
      category: 'translation',
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

  /// Actividades del centro de practica con categorias para filtrar.
  List<LessonActivity> get practicePool => _practicePool;

  /// Opciones disponibles para el BottomSheet de la sección Más.
  List<MoreOption> get moreOptions => _moreOptions;

  /// Devuelve las actividades asignadas a un nodo específico del mapa.
  ///
  /// Cada nodo recibe 2-3 actividades del pool para simular una lección completa.
  List<LessonActivity> getActivitiesForNode(String nodeId) {
    // Distribución fija de actividades del pool de lecciones por nodo
    switch (nodeId) {
      case 'lesson_01':
        return _lessonActivities.sublist(0, 3);
      case 'lesson_02':
        return _lessonActivities.sublist(2, 5);
      case 'lesson_03':
        return _lessonActivities.sublist(1, 4);
      case 'lesson_04':
        return _lessonActivities.sublist(0, 2);
      case 'lesson_05':
        return _lessonActivities.sublist(3, 5);
      case 'lesson_06':
        return _lessonActivities.sublist(0, 3);
      case 'lesson_07':
        return _lessonActivities.sublist(2, 4);
      case 'lesson_08':
        return _lessonActivities.sublist(1, 3);
      case 'lesson_09':
        return _lessonActivities.sublist(0, 4);
      case 'lesson_10':
        return _lessonActivities.sublist(0, 5);
      default:
        return _lessonActivities.take(2).toList();
    }
  }

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