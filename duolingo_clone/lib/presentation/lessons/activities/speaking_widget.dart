import 'package:flutter/material.dart';

import '../../../core/audio_service.dart';
import '../../../core/command.dart';
import '../../../core/speech_service.dart';
import '../../widgets/mascot_animation_widget.dart';

/// Widget de actividad de speaking para repetir lo que dice el personaje.
///
/// La pantalla muestra el personaje, la frase a leer y un boton circular flotante con un microfono.
/// El boton inferior permite saltar la actividad mediante un comando para mantener el flujo de la
/// leccion desacoplado de la UI.
class SpeakingWidget extends StatefulWidget {
  /// Crea la actividad de speaking con su payload y el comando para saltarla.
  const SpeakingWidget({
    super.key,
    required this.payload,
    required this.mascotEmotion,
    required this.onAnswerSelected,
    required this.onSkip,
  });

  /// Datos de la actividad, normalmente con `title` y `sentence`.
  final Map<String, dynamic> payload;

  /// Emoción de la mascota asociada a esta actividad.
  final String mascotEmotion;

  /// Texto reconocido por el micrófono.
  final ValueChanged<String>? onAnswerSelected;

  /// Comando que marca la actividad como saltada en el ViewModel.
  final Command<void>? onSkip;

  @override
  State<SpeakingWidget> createState() => _SpeakingWidgetState();
}

/// Estado interno de [SpeakingWidget] que controla la microinteraccion del boton de microfono.
class _SpeakingWidgetState extends State<SpeakingWidget> {
  bool _isMicPressed = false;
  String _textoDetectado = '';

  @override
  void initState() {
    super.initState();
    SpeechService.instance.initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    final String title = _resolveTitle(widget.payload);
    final String sentence = _resolveSentence(widget.payload);
    final double mascotSize = MediaQuery.of(context).size.height * 0.25;
    final double micSize = MediaQuery.of(context).size.height * 0.13;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: mascotSize,
              child: MascotAnimationWidget.fromEmotion(
                emotion: widget.mascotEmotion,
                width: mascotSize,
                height: mascotSize,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 28),
            _CharacterAndBubble(sentence: sentence),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => AudioService.instance.speak(widget.payload),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2B36),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF364955), width: 2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up_rounded, color: Color(0xFF59C8FF), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'ESCUCHAR FRASE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_textoDetectado.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _textoDetectado,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9FE33A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isMicPressed = true;
                  });
                  SpeechService.instance.startListening((text) {
                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _textoDetectado = text;
                    });
                  });
                },
                onTapCancel: _finishListening,
                onTapUp: (_) => _finishListening(),
                child: AnimatedScale(
                  scale: _isMicPressed ? 0.93 : 1,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: micSize,
                    height: micSize,
                    decoration: BoxDecoration(
                      color: _isMicPressed ? const Color(0xFFFF3B3B) : const Color(0xFF59C8FF),
                      borderRadius: BorderRadius.circular(micSize * 0.25),
                      boxShadow: [
                        BoxShadow(
                          color: _isMicPressed
                              ? const Color(0xFFB80000).withOpacity(0.85)
                              : const Color(0xFF1B8FC2).withOpacity(0.85),
                          offset: const Offset(0, 8),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isMicPressed ? Icons.radio_button_checked_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: micSize * 0.52,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _SkipButton(
              onTap: () => widget.onSkip?.execute(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishListening() async {
    setState(() {
      _isMicPressed = false;
    });

    await SpeechService.instance.stopListening();
    widget.onAnswerSelected?.call(_textoDetectado);
  }

  String _resolveTitle(Map<String, dynamic> payload) {
    final dynamic title = payload['title'] ?? payload['prompt'] ?? payload['instruction'];
    if (title is String && title.trim().isNotEmpty) {
      return title.trim();
    }

    return 'Repite lo que dice Lily';
  }

  String _resolveSentence(Map<String, dynamic> payload) {
    final dynamic sentence = payload['sentence'] ?? payload['audioText'] ?? payload['subtitle'];
    if (sentence is String && sentence.trim().isNotEmpty) {
      return sentence.trim();
    }

    return 'We like to play.';
  }
}

/// Composicion visual del personaje y el globo de texto para la actividad de speaking.
class _CharacterAndBubble extends StatelessWidget {
  /// Crea la composicion visual principal.
  const _CharacterAndBubble({required this.sentence});

  final String sentence;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF111A22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF364955), width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF35B8FF).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_rounded, color: Color(0xFF35B8FF), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sentence,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: 220,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            gradient: const LinearGradient(
              colors: [Color(0xFF6F49C8), Color(0xFF32224C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.record_voice_over_rounded,
            color: Colors.white,
            size: 110,
          ),
        ),
      ],
    );
  }
}

/// Boton inferior para omitir la actividad de speaking.
class _SkipButton extends StatelessWidget {
  /// Crea el boton que dispara el comando de salto.
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF2A333B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2F3E46), width: 2),
        ),
        alignment: Alignment.center,
        child: const Text(
          'NO PUEDO HABLAR AHORA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
