import 'package:flutter/material.dart';

import '../../../core/audio_service.dart';
import '../../widgets/mascot_animation_widget.dart';

/// Widget que permite traducir una oracion ordenando bloques de palabras.
///
/// La parte superior muestra la oracion en ingles dentro de un globo con un boton de bocina.
/// En el medio se renderiza el area de respuesta con renglones visuales. En la parte inferior
/// aparece el banco de palabras, y tocar un bloque lo mueve entre el banco y la respuesta.
class TranslateSentenceWidget extends StatefulWidget {
  /// Crea el widget de traduccion de oracion.
  const TranslateSentenceWidget({
    super.key,
    required this.promptText,
    required this.correctAnswerText,
    required this.mascotEmotion,
    this.payload,
    this.onAnswerSelected,
  });

  /// Oración en el idioma origen que el usuario debe traducir.
  final String promptText;

  /// Traducción correcta esperada, usada para construir el banco de palabras.
  final String correctAnswerText;

  /// Emoción de la mascota asociada a esta actividad.
  final String mascotEmotion;

  /// Payload dinámico con datos específicos de la actividad.
  final Map<String, dynamic>? payload;

  /// Callback que reporta la respuesta construida por el usuario.
  final ValueChanged<String>? onAnswerSelected;

  @override
  State<TranslateSentenceWidget> createState() => _TranslateSentenceWidgetState();
}

/// Estado interno de [TranslateSentenceWidget] que administra los bloques seleccionados.
class _TranslateSentenceWidgetState extends State<TranslateSentenceWidget> {
  late final List<String> _availableWords;
  late final List<String> _responseWords;

  @override
  void initState() {
    super.initState();
    _availableWords = _buildAvailableWords();
    _responseWords = <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> mapPayload = widget.payload is Map
        ? Map<String, dynamic>.from(widget.payload!)
        : {};
    final String sentenceToTranslate =
        mapPayload['sentence'] ?? mapPayload['text'] ?? 'Oración faltante';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MascotAnimationWidget.fromEmotion(
            emotion: widget.mascotEmotion,
            width: 128,
            height: 128,
          ),
          const SizedBox(height: 8),
          _SentenceBubble(
            sentence: sentenceToTranslate,
          ),
          const SizedBox(height: 22),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111A22),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _UnderlinePainter(),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final word in _responseWords)
                                    _WordChip(
                                      text: word,
                                      selected: true,
                                      onTap: () {
                                        setState(() {
                                          _responseWords.remove(word);
                                          _availableWords.add(word);
                                        });
                                        widget.onAnswerSelected?.call(_responseWords.join(' '));
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final word in _availableWords)
                      _WordChip(
                        text: word,
                        onTap: () {
                          setState(() {
                            _availableWords.remove(word);
                            _responseWords.add(word);
                          });
                          widget.onAnswerSelected?.call(_responseWords.join(' '));
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildAvailableWords() {
    if (widget.correctAnswerText.isEmpty) return ['Error:', 'Respuesta', 'vacía'];
    final words = widget.correctAnswerText
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    words.shuffle();
    return words;
  }
}

/// Globo superior que muestra la frase objetivo con un acceso rapido a audio.
class _SentenceBubble extends StatelessWidget {
  /// Crea el globo de la frase.
  const _SentenceBubble({required this.sentence});

  final String sentence;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            AudioService.instance.speak(sentence);
          },
          child: const Icon(Icons.record_voice_over_rounded, color: Color(0xFF35B8FF), size: 56),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF121E28),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF364955), width: 2),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    AudioService.instance.speak(sentence);
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF35B8FF).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Color(0xFF35B8FF), size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sentence,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bloque reutilizable para mostrar una palabra como boton interactivo.
class _WordChip extends StatelessWidget {
  /// Crea un chip de palabra.
  const _WordChip({required this.text, required this.onTap, this.selected = false});

  final String text;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF163452) : const Color(0xFF1A2430),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF6DCBFF) : const Color(0xFF32424F),
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFFD7F2FF) : Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Pintura simple de renglones horizontales para simular el area de respuesta.
class _UnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    return; // TODO: Bug de bucle infinito en Web CanvasKit.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}