import 'package:flutter/material.dart';

/// Muestra un bottom sheet de retroalimentación para ejercicios.
///
/// El sheet arranca con la retroalimentación básica y, cuando el usuario toca "EXPLICA MI ERROR",
/// se expande para mostrar una tarjeta de explicación IA con tips gramaticales simulados.
///
/// Uso:
/// await showFeedbackSheet(context, isCorrect: true, onContinue: () { ... });
Future<void> showFeedbackSheet(
  BuildContext context, {
  required bool isCorrect,
  String? correctAnswer,
  String? aiExplanation,
  VoidCallback? onContinue,
}) {
  const Color correctBg = Color(0xFFE9F7D9);
  const Color correctTitle = Color(0xFF2E6E16);
  const Color primaryGreen = Color(0xFF8CE317);
  const Color primaryGreenShadow = Color(0xFF5FA10F);

  const Color wrongBg = Color(0xFFF9D6D6);
  const Color wrongTitle = Color(0xFF7A1E1E);

  final String explanationText =
      aiExplanation?.trim().isNotEmpty == true
          ? aiExplanation!.trim()
          : 'Revisa el sujeto, el verbo y el contexto para elegir la opción correcta. La respuesta suele encajar por gramática, significado y orden natural de la oración.';

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return _FeedbackSheetContent(
        isCorrect: isCorrect,
        correctAnswer: correctAnswer,
        explanationText: explanationText,
        onContinue: onContinue,
      );
    },
  );
}

/// Cuerpo interactivo del bottom sheet de retroalimentación.
class _FeedbackSheetContent extends StatefulWidget {
  /// Crea el contenido del sheet con su estado inicial.
  const _FeedbackSheetContent({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanationText,
    required this.onContinue,
  });

  final bool isCorrect;
  final String? correctAnswer;
  final String explanationText;
  final VoidCallback? onContinue;

  @override
  State<_FeedbackSheetContent> createState() => _FeedbackSheetContentState();
}

/// Estado interno del bottom sheet que maneja la expansión de la explicación IA.
class _FeedbackSheetContentState extends State<_FeedbackSheetContent> with TickerProviderStateMixin {
  bool _showAiExplanation = false;

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF8CE317);
    const Color primaryGreenShadow = Color(0xFF5FA10F);

    const Color wrongBg = Color(0xFFF9D6D6);
    const Color wrongTitle = Color(0xFF7A1E1E);
    const Color wrongAccent = Color(0xFFB94A4A);

    const Color aiCardBg = Color(0xFFDFF4FF);
    const Color aiIcon = Color(0xFF24A0E0);
    const Color aiText = Color(0xFF071526);
    const Color aiChipBg = Color(0xFFEAF6FF);
    const Color aiChipBorder = Color(0xFF9CD7FF);

    final bool isCorrect = widget.isCorrect;
    final Color topBg = isCorrect ? const Color(0xFFE9F7D9) : wrongBg;
    final Color titleColor = isCorrect ? const Color(0xFF2E6E16) : wrongTitle;
    final IconData statusIcon = isCorrect ? Icons.check_rounded : Icons.close_rounded;
    final Color statusIconColor = isCorrect ? Colors.white : wrongTitle;
    final String title = isCorrect ? '¡Muy bien!' : 'Incorrecto';

    return SafeArea(
      top: false,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1A1C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: topBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isCorrect ? primaryGreen : wrongTitle.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            statusIcon,
                            color: statusIconColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect && (widget.correctAnswer != null && widget.correctAnswer!.isNotEmpty)) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Respuesta correcta:',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.correctAnswer!,
                        style: const TextStyle(
                          color: Color(0xFF0F1A1C),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!isCorrect) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3C4A54), width: 3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() {
                        _showAiExplanation = !_showAiExplanation;
                      });
                    },
                    child: Text(
                      _showAiExplanation ? 'OCULTAR EXPLICACIÓN' : 'EXPLICA MI ERROR',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 260),
                crossFadeState: _showAiExplanation ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: aiCardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: aiIcon.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.smart_toy_rounded, color: aiIcon),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Explicación IA',
                              style: TextStyle(
                                color: aiText,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.explanationText,
                        style: const TextStyle(
                          color: aiText,
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _AiBullet(
                        icon: Icons.circle,
                        text: 'Piensa en el contexto completo antes de elegir una palabra.',
                      ),
                      const SizedBox(height: 8),
                      _AiBullet(
                        icon: Icons.circle,
                        text: 'Revisa si el verbo, el sujeto o el orden de la frase cambian la respuesta.',
                      ),
                      const SizedBox(height: 8),
                      _AiBullet(
                        icon: Icons.circle,
                        text: 'En ejercicios de traducción, la solución correcta suele sonar natural y no literal.',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Icon(Icons.thumb_down_alt_outlined, color: Color(0xFF6B7C87), size: 26),
                          SizedBox(width: 14),
                          Icon(Icons.thumb_up_alt_outlined, color: Color(0xFF6B7C87), size: 26),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (isCorrect)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (widget.onContinue != null) {
                      widget.onContinue!();
                    }
                  },
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreenShadow.withOpacity(0.85),
                          offset: const Offset(0, 8),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        color: Color(0xFF09220A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Viñeta amigable para la tarjeta de explicación IA.
class _AiBullet extends StatelessWidget {
  /// Crea una línea con viñeta e instrucciones.
  const _AiBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 8, color: Color(0xFF24A0E0)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF071526),
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
