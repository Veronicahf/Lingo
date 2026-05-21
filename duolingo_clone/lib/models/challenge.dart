import 'package:flutter/material.dart';

/// Modelo de datos que representa un desafio reutilizable dentro de la app.
///
/// Esta entidad centraliza la informacion visible y de progreso de cada desafio para que la
/// vista pueda pintarlo desde datos estructurados y no desde tarjetas hardcodeadas.
class Challenge {
  /// Crea un desafio con su estado y configuracion visual.
  const Challenge({
    required this.title,
    required this.currentProgress,
    required this.goal,
    required this.icon,
    this.eyebrow,
    this.progressColor,
    this.actionLabel,
    this.actionIcon,
    this.chestStyle = ChallengeChestStyle.locked,
    this.lockedSubtitle,
    this.isLocked = false,
  });

  /// Titulo principal del desafio.
  final String title;

  /// Progreso actual acumulado por el usuario.
  final int currentProgress;

  /// Meta total necesaria para completar el desafio.
  final int goal;

  /// Icono asociado al desafio.
  final IconData icon;

  /// Texto superior opcional que contextualiza la tarjeta.
  final String? eyebrow;

  /// Color de la barra de progreso cuando se quiere enfatizar una tarjeta.
  final Color? progressColor;

  /// Texto del boton de accion, si aplica.
  final String? actionLabel;

  /// Icono del boton de accion, si aplica.
  final IconData? actionIcon;

  /// Estilo visual del cofre asociado al desafio.
  final ChallengeChestStyle chestStyle;

  /// Subtitulo para desafios bloqueados o proximos.
  final String? lockedSubtitle;

  /// Indica si el desafio esta bloqueado.
  final bool isLocked;

  /// Progreso normalizado entre 0 y 1.
  double get progressValue => goal == 0 ? 0.0 : currentProgress / goal;

  /// Texto de progreso ya formateado para la UI.
  String get progressLabel => '$currentProgress / $goal';
}

/// Variante visual del cofre del desafio.
enum ChallengeChestStyle {
  /// Cofre para desafios entre amigos.
  friend,

  /// Cofre para desafio diario.
  daily,

  /// Cofre bloqueado o futuro.
  locked,
}