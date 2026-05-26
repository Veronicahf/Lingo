/// Modelo de un dia del calendario de racha.
///
/// Este objeto permite pintar el calendario de forma declarativa, manteniendo la vista libre
/// de la logica de estado visual de cada dia.
class StreakCalendarDay {
  /// Crea un dia del calendario con su estado visual.
  const StreakCalendarDay({
    required this.dayNumber,
    this.isFrozen = false,
    this.isToday = false,
    this.isStreakDay = false,
  });

  /// Numero de dia dentro del calendario.
  final int dayNumber;

  /// Indica si el dia se muestra como congelado.
  final bool isFrozen;

  /// Indica si el dia corresponde al dia actual.
  final bool isToday;

  /// Indica si el dia pertenece a la racha activa.
  final bool isStreakDay;
}