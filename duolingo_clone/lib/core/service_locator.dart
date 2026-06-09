import 'audio_service.dart';
import '../repositories/course_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/shop_repository.dart';
import '../repositories/user_repository.dart';
import '../viewmodels/profile_viewmodel.dart';

class ServiceLocator {
  ServiceLocator._();

  static late AudioService _audioService;
  static late MockUserRepository _userRepository;
  static late MockCourseRepository _courseRepository;
  static late MockNewsRepository _newsRepository;
  static late MockShopRepository _shopRepository;
  static late ProfileViewModel _profileViewModel;

  static bool _registrationRequired = false;
  static bool _isRegistered = false;
  static int _completedLessonsCount = 0;
  static int _lastCompletedLessonIndex = -1;
  static List<String>? _onboardingAnswers;

  static bool get registrationRequired => _registrationRequired;
  static bool get isRegistered => _isRegistered;
  static int get completedLessonsCount => _completedLessonsCount;
  static int get lastCompletedLessonIndex => _lastCompletedLessonIndex;
  static List<String>? get onboardingAnswers => _onboardingAnswers;

  static void markRegistrationRequired() {
    _registrationRequired = true;
  }

  static void markRegistrationComplete() {
    _registrationRequired = false;
    _isRegistered = true;
  }

  static void incrementCompletedLessons() {
    _completedLessonsCount++;
  }

  static void setLastCompletedLessonIndex(int index) {
    _lastCompletedLessonIndex = index;
  }

  static void setOnboardingAnswers(List<String> answers) {
    _onboardingAnswers = answers;
  }

  static void init() {
    _audioService = AudioService.instance;
    _userRepository = const MockUserRepository();
    _courseRepository = const MockCourseRepository();
    _newsRepository = const MockNewsRepository();
    _shopRepository = const MockShopRepository();
    _profileViewModel = ProfileViewModel();
  }

  static AudioService get audioService => _audioService;
  static MockUserRepository get userRepository => _userRepository;
  static MockCourseRepository get courseRepository => _courseRepository;
  static MockNewsRepository get newsRepository => _newsRepository;
  static MockShopRepository get shopRepository => _shopRepository;
  static ProfileViewModel get profileViewModel => _profileViewModel;
}
