import 'package:flutter/material.dart';

import '../../core/command.dart';
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
class LessonFactory {
  /// Construye el widget visual asociado a una actividad de leccion.
  static Widget buildActivity(LessonActivity activity, Function(String) onAnswerSelected,
      {Command<void>? onRepeatSkip}) {
    switch (activity.type) {
      case ActivityType.completeDialog:
      case ActivityType.fillBlank:
        return FillBlankWidget(
          payload: _asFillBlankPayload(activity.payload),
          isDialogStyle: activity.type == ActivityType.completeDialog,
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.listenSelect:
        return ListeningWidget(
          payload: _asListeningPayload(activity.payload),
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.repeat:
        return SpeakingWidget(
          payload: _asSpeakingPayload(activity.payload),
          onSkip: onRepeatSkip,
        );
      case ActivityType.matchPairs:
        return MatchPairsWidget(
          payload: _asMatchPairsPayload(activity.payload),
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.selectTranslation:
        return SelectTranslationWidget(
          payload: _asSelectTranslationPayload(activity.payload),
          onAnswerSelected: onAnswerSelected,
        );
      case ActivityType.translateSentence:
        return TranslateSentenceWidget(
          payload: _asTranslateSentencePayload(activity.payload),
          onAnswerSelected: onAnswerSelected,
        );
    }
  }

  static List<String> _asStringOptions(dynamic payload) {
    if (payload is List<String>) {
      return List<String>.unmodifiable(payload);
    }

    if (payload is List) {
      return List<String>.unmodifiable(payload.whereType<String>());
    }

    final dynamic options = payload is Map ? payload['options'] : null;
    if (options is List) {
      return List<String>.unmodifiable(options.whereType<String>());
    }

    return const <String>[];
  }

  static Map<String, String> _asMatchPairsPayload(dynamic payload) {
    if (payload is Map) {
      return Map<String, String>.unmodifiable(
        payload.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }

    final dynamic pairs = payload is Map ? payload['pairs'] : null;
    if (pairs is Map) {
      return Map<String, String>.unmodifiable(
        pairs.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }

    return const <String, String>{};
  }

  static Map<String, dynamic> _asSelectTranslationPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(payload);
    }

    if (payload is Map) {
      return Map<String, dynamic>.unmodifiable(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return <String, dynamic>{'options': _asStringOptions(payload)};
  }

  static Map<String, dynamic> _asTranslateSentencePayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(payload);
    }

    if (payload is Map) {
      return Map<String, dynamic>.unmodifiable(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _asFillBlankPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(payload);
    }

    if (payload is Map) {
      return Map<String, dynamic>.unmodifiable(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _asListeningPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(payload);
    }

    if (payload is Map) {
      return Map<String, dynamic>.unmodifiable(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    if (payload is List) {
      return <String, dynamic>{'options': _asStringOptions(payload)};
    }

    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _asSpeakingPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(payload);
    }

    if (payload is Map) {
      return Map<String, dynamic>.unmodifiable(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return const <String, dynamic>{};
  }
}
