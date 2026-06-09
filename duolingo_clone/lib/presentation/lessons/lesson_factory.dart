import 'package:flutter/material.dart';

import '../../core/command.dart';
import '../../models/dtos/lesson_dto.dart';
import '../../models/lesson_activity.dart';
import 'activities/fill_blank_widget.dart';
import 'activities/match_pairs_widget.dart';
import 'activities/listening_widget.dart';
import 'activities/select_translation_widget.dart';
import 'activities/translate_sentence_widget.dart';
import 'activities/speaking_widget.dart';

/// Fabrica que inyecta los juegos dentro del cascaron de la leccion.
///
/// Esta clase concentra la seleccion del widget correcto para cada tipo de actividad
/// y permite desacoplar el contenedor de leccion de la implementacion concreta del juego.
/// Recibe [LessonDTO] para aislar la UI de la estructura de base de datos.
class LessonFactory {
  /// Construye el widget visual asociado a una actividad de leccion.
  static Widget buildActivity(LessonDTO dto, Function(String) onAnswerSelected,
      {Command<void>? onRepeatSkip}) {
    switch (dto.type) {
      case ActivityType.completeDialog:
      case ActivityType.fillBlank:
        return FillBlankWidget(
          payload: dto.payload,
          isDialogStyle: dto.type == ActivityType.completeDialog,
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.listenSelect:
        return ListeningWidget(
          payload: dto.payload,
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.repeat:
        return SpeakingWidget(
          payload: dto.payload,
          mascotEmotion: dto.mascotEmotion,
          onAnswerSelected: onAnswerSelected,
          onSkip: onRepeatSkip,
        );
      case ActivityType.matchPairs:
        return MatchPairsWidget(
          payload: _asMatchPairsPayload(dto.payload),
          onAnswerSelected: onAnswerSelected,
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
    }
  }

  static Map<String, String> _asMatchPairsPayload(Map<String, dynamic> payload) {
    final dynamic pairs = payload['pairs'] ?? payload;
    if (pairs is Map) {
      return Map<String, String>.unmodifiable(
        pairs.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }
    return const <String, String>{};
  }
}
