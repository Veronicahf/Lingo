import 'package:speech_to_text/speech_to_text.dart';

/// Servicio singleton para reconocimiento de voz.
class SpeechService {
  SpeechService._();

  /// Instancia compartida del servicio.
  static final SpeechService instance = SpeechService._();

  final SpeechToText _speechToText = SpeechToText();
  bool _initialized = false;

  /// Inicializa el motor de reconocimiento de voz.
  Future<bool> initSpeech() async {
    if (_initialized) {
      return _speechToText.isAvailable;
    }

    _initialized = true;
    return _speechToText.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
  }

  /// Inicia la escucha y emite el texto reconocido en cada actualización.
  Future<void> startListening(void Function(String text) onResult) async {
    final bool available = await initSpeech();
    if (!available) {
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenMode: ListenMode.confirmation,
    );
  }

  /// Detiene la escucha activa.
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }
}