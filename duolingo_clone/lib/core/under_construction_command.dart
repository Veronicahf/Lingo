import 'package:flutter/material.dart';

import 'command.dart';

/// Comando reutilizable para señalar acciones aún no implementadas.
///
/// Esta clase muestra un SnackBar discreto y consistente para mantener la experiencia pulida
/// mientras una función sigue en desarrollo.
class UnderConstructionCommand implements Command<void> {
  /// Crea el comando de función en construcción.
  const UnderConstructionCommand();

  @override
  void execute([BuildContext? context]) {
    if (context == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            '🛠️ Función en construcción',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Color(0xFF2B3138),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );
  }
}