import 'package:flutter/material.dart';

/// Muestra un bottom sheet de retroalimentación para ejercicios.
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
  const Color _correctBg = Color(0xFFE9F7D9);
  const Color _correctTitle = Color(0xFF2E6E16);
  const Color _primaryGreen = Color(0xFF8CE317);
  const Color _primaryGreenShadow = Color(0xFF5FA10F);

  const Color _wrongBg = Color(0xFFF9D6D6);
  const Color _wrongTitle = Color(0xFF7A1E1E);

  const Color _aiCardBg = Color(0xFFDFF4FF);
  const Color _aiIcon = Color(0xFF24A0E0);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return SafeArea(
        top: false,
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
                  color: isCorrect ? _correctBg : _wrongBg,
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
                            color: isCorrect ? _primaryGreen : _wrongTitle.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_rounded : Icons.close_rounded,
                            color: isCorrect ? Colors.white : _wrongTitle,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isCorrect ? '¡Muy bien!' : 'Respuesta incorrecta',
                            style: TextStyle(
                              color: isCorrect ? _correctTitle : _wrongTitle,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect && (correctAnswer != null && correctAnswer.isNotEmpty)) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Respuesta correcta: $correctAnswer',
                        style: const TextStyle(color: Color(0xFF0F1A1C), fontWeight: FontWeight.w800),
                      ),
                    ],
                    if (!isCorrect && aiExplanation != null && aiExplanation.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _aiCardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _aiIcon.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.smart_toy_rounded, color: _aiIcon),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                aiExplanation,
                                style: const TextStyle(color: Color(0xFF071526)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              if (!isCorrect)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3C4A54), width: 3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      'EXPLICA MI RESPUESTA',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (onContinue != null) onContinue();
                },
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGreenShadow.withOpacity(0.85),
                        offset: const Offset(0, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isCorrect ? 'CONTINUAR' : 'CONTINUAR',
                    style: const TextStyle(
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
      );
    },
  );
}
