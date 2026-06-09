import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../core/api_client.dart';
import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/lesson_node.dart';
import '../models/user_profile.dart';
import '../repositories/course_repository.dart';
import '../repositories/user_repository.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel(
      {MockCourseRepository? courseRepository,
      MockUserRepository? userRepository})
      : _courseRepository =
            courseRepository ?? ServiceLocator.courseRepository,
        _userRepository =
            userRepository ?? ServiceLocator.userRepository;

  final MockCourseRepository _courseRepository;
  final MockUserRepository _userRepository;

  List<LessonNode> _lessonNodes = const [];
  UserProfile? _profile;

  List<LessonNode> get lessonNodes => _lessonNodes;
  UserProfile? get profile => _profile;

  String get currentSectionTitle => 'Sección $_currentSectionNumber';

  String get currentStageTitle {
    final currentLesson = _currentLessonNode;
    final stageName = currentLesson?.title ?? 'Primeros pasos';
    return 'Etapa $_currentSectionNumber: $stageName';
  }

  String get currentCourseName =>
      _profile?.leagueName ?? 'Curso de inglés';

  String get currentCourseScore =>
      _profile == null ? '...' : '${_profile!.totalXp} EXP';

  String get streakDaysText =>
      _profile == null ? '...' : '${_profile!.streakDays}';

  String get gemsText => _profile == null ? '...' : '${_profile!.gems}';

  String get heartsValueText => _profile == null ? '...' : '∞';
  String get energyDialogTitle => 'Energía ilimitada';
  String get energyDialogSubtitle =>
      'Sigue aprendiendo sin interrupciones.';
  String get coursesButtonLabel => 'Cursos';
  String get energyButtonLabel => 'Continuar';

  bool _isLoggedIn() {
    try {
      return fb.FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadLessonNodes() async {
    setLoading(true);

    if (!_isLoggedIn()) {
      refreshDemoNodes();
      setSuccess();
      return;
    }

    try {
      final response =
          await ApiClient.instance.get('/api/v1/lessons/map');
      final data = response.data;
      final List<LessonNode> remoteNodes;

      if (data is List) {
        remoteNodes = data
            .map((e) => LessonNode.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        remoteNodes = await _courseRepository.getLessonNodes();
      }

      _lessonNodes = _applyStrictProgression(remoteNodes);
      setSuccess();
    } catch (_) {
      setError('No se pudo cargar el mapa de lecciones.');
    }
  }

  void refreshDemoNodes() {
    _lessonNodes = _buildDemoNodes(ServiceLocator.completedLessonsCount);
    notifyListeners();
  }

  List<LessonNode> _buildDemoNodes(int completed) {
    return <LessonNode>[
      LessonNode(
        id: 'demo_1',
        title: 'Primeros pasos',
        type: LessonNodeType.star,
        status: completed >= 1
            ? NodeStatus.completed
            : NodeStatus.active,
        position: const Offset(0, 0),
        activities: const [],
      ),
      LessonNode(
        id: 'demo_2',
        title: 'Palabras básicas',
        type: LessonNodeType.star,
        status: completed >= 2
            ? NodeStatus.completed
            : completed >= 1
                ? NodeStatus.active
                : NodeStatus.locked,
        position: const Offset(0, 1),
        activities: const [],
      ),
      LessonNode(
        id: 'demo_3',
        title: 'Siguiente lección',
        type: LessonNodeType.book,
        status: NodeStatus.locked,
        position: const Offset(0, 2),
        activities: const [],
      ),
    ];
  }

  List<LessonNode> _applyStrictProgression(List<LessonNode> nodes) {
    if (nodes.isEmpty) return nodes;

    final firstUncompletedIndex =
        nodes.indexWhere((n) => n.status != NodeStatus.completed);

    if (firstUncompletedIndex == -1) return nodes;

    return List<LessonNode>.generate(nodes.length, (index) {
      NodeStatus newStatus;
      if (index < firstUncompletedIndex) {
        newStatus = NodeStatus.completed;
      } else if (index == firstUncompletedIndex) {
        newStatus = NodeStatus.active;
      } else {
        newStatus = NodeStatus.locked;
      }

      return LessonNode(
        id: nodes[index].id,
        title: nodes[index].title,
        type: nodes[index].type,
        status: newStatus,
        position: nodes[index].position,
        activities: nodes[index].activities,
      );
    });
  }

  Future<void> loadProfile() async {
    setLoading(true);
    try {
      _profile = await _userRepository.getUserProfile();
      setSuccess();
    } catch (_) {
      setError('No se pudo cargar el perfil del Home.');
    }
  }

  LessonNode? get _currentLessonNode {
    if (_lessonNodes.isEmpty) return null;

    final activeIndex =
        _lessonNodes.indexWhere((n) => n.status == NodeStatus.active);
    if (activeIndex != -1) return _lessonNodes[activeIndex];

    final lastCompletedIndex = _lessonNodes
        .lastIndexWhere((n) => n.status == NodeStatus.completed);
    if (lastCompletedIndex != -1 &&
        lastCompletedIndex + 1 < _lessonNodes.length) {
      return _lessonNodes[lastCompletedIndex + 1];
    }

    return _lessonNodes.first;
  }

  int get _currentSectionNumber {
    if (_lessonNodes.isEmpty) return 1;
    final currentIndex =
        _lessonNodes.indexOf(_currentLessonNode ?? _lessonNodes.first);
    if (currentIndex < 0) return 1;
    return (currentIndex ~/ 3) + 1;
  }
}
