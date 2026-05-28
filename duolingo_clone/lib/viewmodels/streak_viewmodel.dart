import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/streak_calendar_day.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

/// ViewModel que expone el estado de la pantalla de racha.
///
/// Esta clase consume el repositorio mock de usuario para obtener la racha actual y genera
/// un calendario simulado sin mezclar datos ni logica visual dentro de la vista.
class StreakViewModel extends BaseViewModel {
  /// Crea la ViewModel de racha con repositorio opcional inyectado.
  ///
  /// Si no se proporciona uno, se usa la instancia registrada en [ServiceLocator].
  StreakViewModel({MockUserRepository? userRepository})
      : _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockUserRepository _userRepository;

  UserProfile? _profile;
  List<StreakCalendarDay> _personalCalendar = const [];
  List<DateTime> _activeStreakDates = const [];

  /// Perfil del usuario usado en la cabecera de racha.
  UserProfile? get profile => _profile;

  /// Dias consecutivos actuales.
  int get streakDays => _profile?.streakDays ?? 0;

  /// Calendario simulado de la pestaña personal.
  List<StreakCalendarDay> get personalCalendar => _personalCalendar;

  /// Fechas activas de la racha calculadas a partir del usuario actual.
  List<DateTime> get activeStreakDates => _activeStreakDates;

  /// Cantidad de protectores de racha disponibles.
  int get streakProtectors => 0;

  /// Texto del botón principal para invitar amigos.
  String get inviteFriendsLabel => 'Añadir amigos';

  /// Mensaje descriptivo para la pestaña Entre amigos.
  String get friendsEmptyStateText => 'Aún no tienes amigos activos en tu racha.';

  /// Título del bloque de protectores de racha.
  String get protectorsTitle => 'Protectores de racha';

  /// Descripción del estado de los protectores de racha.
  String get protectorsDescription => 'Tienes 0 protectores disponibles en este momento.';

  /// Título de la pestaña personal.
  String get personalTabLabel => 'Personal';

  /// Título de la pestaña entre amigos.
  String get friendsTabLabel => 'Entre amigos';

  /// Carga los datos de la racha y construye un calendario mock visual.
  Future<void> loadStreakData() async {
    setLoading(true);

    try {
      _profile = await _userRepository.getUserProfile();
      _activeStreakDates = _buildActiveStreakDates(_profile?.streakDays ?? 0);
      _personalCalendar = _buildPersonalCalendar();
      setSuccess();
    } catch (error) {
      setError('No se pudo cargar la pantalla de racha.');
    }
  }

  List<DateTime> _buildActiveStreakDates(int streakDays) {
    if (streakDays <= 0) {
      return const [];
    }

    final DateTime today = _dateOnly(DateTime.now());

    return List<DateTime>.generate(
      streakDays,
      (index) => today.subtract(Duration(days: index)),
      growable: false,
    );
  }

  List<StreakCalendarDay> _buildPersonalCalendar() {
    final DateTime monthStart = DateTime(2026, 5, 20);
    final DateTime today = _dateOnly(DateTime.now());

    return List<StreakCalendarDay>.generate(12, (index) {
      final DateTime date = _dateOnly(monthStart.add(Duration(days: index)));
      final bool isStreakDay = activeStreakDates.any((activeDate) => _isSameDay(activeDate, date));

      return StreakCalendarDay(
        dayNumber: date.day,
        date: date,
        isFrozen: date.isAfter(today),
        isToday: _isSameDay(date, today),
        isStreakDay: isStreakDay,
      );
    }, growable: false);
  }

  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month && left.day == right.day;
  }
}