import 'package:flutter_tts/flutter_tts.dart';

/// Servicio singleton que encapsula la reproduccion de audio por texto.
///
/// Esta capa centraliza la configuracion de `flutter_tts` para que las actividades de leccion
/// puedan reproducir su contenido sin acoplar la UI al motor de voz.
class AudioService {
  /// Crea el servicio de audio con una instancia compartida de `FlutterTts`.
  AudioService._() {
    _initialize();
  }

  /// Instancia compartida del servicio de audio.
  static final AudioService instance = AudioService._();

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _initialize() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);
  }

  /// Reproduce el texto recibido usando síntesis de voz.
  Future<void> speak(String text) async {
    final String normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return;
    }

    await _flutterTts.stop();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.speak(normalizedText);
  }
}