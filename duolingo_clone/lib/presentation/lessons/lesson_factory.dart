import 'package:flutter/material.dart';

import '../../core/command.dart';
import '../../models/dtos/lesson_dto.dart';
import '../../models/lesson_activity.dart';
import 'activities/fill_blank_widget.dart';
import 'activities/listening_widget.dart';
import 'activities/select_translation_widget.dart';
import 'activities/speaking_widget.dart';
import 'activities/translate_sentence_widget.dart';

/// Fabrica que inyecta los juegos dentro del cascaron de la leccion.
///
/// Esta clase concentra la seleccion del widget correcto para cada tipo de actividad
/// y permite desacoplar el contenedor de leccion de la implementacion concreta del juego.
/// Recibe [LessonDTO] para aislar la UI de la estructura de base de datos.
class LessonFactory {
  /// Construye el widget visual asociado a una actividad de leccion.
  static Widget buildActivity(LessonDTO dto, Function(String) onAnswerSelected,
      {Command<void>? onSkip}) {
    switch (dto.type) {
      case ActivityType.fillBlank:
        return FillBlankWidget(
          payload: dto.payload,
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.listenSelect:
        return ListeningWidget(
          payload: dto.payload,
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.speaking:
        return SpeakingWidget(
          payload: dto.payload,
          mascotEmotion: dto.mascotEmotion,
          onAnswerSelected: onAnswerSelected,
          onSkip: onSkip,
        );
      case ActivityType.selectTranslation:
        return SelectTranslationWidget(
          payload: dto.payload,
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.translateSentence:
        return TranslateSentenceWidget(
          payload: dto.payload,
          mascotEmotion: dto.mascotEmotion,
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.unknown:
        return _UnsupportedActivity(onSkip: onSkip);
    }
  }
}

/// Widget de respaldo que se muestra cuando la IA devuelve un tipo de actividad
/// desconocido o no soportado. Permite saltar la actividad sin bloquear la leccion.
class _UnsupportedActivity extends StatelessWidget {
  const _UnsupportedActivity({this.onSkip});

  final Command<void>? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_outline_rounded, color: Color(0xFF9AA7B1), size: 64),
          const SizedBox(height: 16),
          const Text(
            'Actividad no soportada',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta actividad aun no esta disponible.\nPuedes saltarla para continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9AA7B1),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => onSkip?.execute(context),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF2A333B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2F3E46), width: 2),
              ),
              alignment: Alignment.center,
              child: const Text(
                'SALTAR ACTIVIDAD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
