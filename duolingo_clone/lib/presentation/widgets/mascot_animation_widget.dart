import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Componente centralizado para renderizar la mascota animada de la app.
///
/// Este widget aísla la carga de animaciones Lottie para que la UI reutilice una sola
/// implementacion consistente, con un fallback visual sencillo cuando el asset no esta disponible.
class MascotAnimationWidget extends StatelessWidget {
  /// Crea un renderizador de mascota animada con asset Lottie configurable.
  const MascotAnimationWidget({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
  });

  /// Crea un renderizador de mascota animada a partir de una emoción de UI.
  factory MascotAnimationWidget.fromEmotion({
    Key? key,
    required String emotion,
    required double width,
    required double height,
  }) {
    return MascotAnimationWidget(
      key: key,
      assetPath: assetPathForEmotion(emotion),
      width: width,
      height: height,
    );
  }

  /// Resuelve la ruta del asset a partir de la emoción de la mascota.
  static String assetPathForEmotion(String emotion) {
    switch (emotion.trim().toLowerCase()) {
      case 'happy':
        return 'assets/lottie/cat_happy.json';
      case 'speaking':
      case 'typing':
        return 'assets/lottie/Cat_typing.json';
      case 'sad':
        return 'assets/lottie/cat_sad.json';
      case 'sleeping':
        return 'assets/lottie/cat_sleeping.json';
      case 'rocket':
        return 'assets/lottie/Cat_in_a_rocket.json';
      case 'idle':
      default:
        return 'assets/lottie/cat_idle.json';
    }
  }

  /// Ruta del archivo JSON de Lottie dentro de assets.
  final String assetPath;

  /// Ancho del componente renderizado.
  final double width;

  /// Alto del componente renderizado.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: const Icon(
            Icons.pets_rounded,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
