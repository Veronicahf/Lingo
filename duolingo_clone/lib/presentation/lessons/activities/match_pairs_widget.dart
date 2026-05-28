import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget que presenta dos columnas de palabras para emparejarlas.
///
/// Recibe un payload en formato mapa donde la clave es la palabra en español y el valor su
/// traducción en inglés. Cada lista se mezcla por separado para evitar que queden alineadas.
class MatchPairsWidget extends StatefulWidget {
  /// Crea el widget de emparejamiento con sus pares disponibles.
  const MatchPairsWidget({super.key, required this.payload, this.onAnswerSelected});

  /// Pares que forman el juego, usando la palabra en español como clave.
  final Map<String, String> payload;

  /// Callback que reporta el estado actual de los pares emparejados.
  final ValueChanged<String>? onAnswerSelected;

  @override
  State<MatchPairsWidget> createState() => _MatchPairsWidgetState();
}

/// Estado interno de [MatchPairsWidget] que administra selecciones, aciertos y errores.
class _MatchPairsWidgetState extends State<MatchPairsWidget> {
  late final List<String> _spanishWords;
  late final List<String> _englishWords;
  late final Map<String, String> _pairBySpanish;

  String? _selectedSpanish;
  String? _selectedEnglish;
  final Set<String> _matchedIds = <String>{};
  final Set<String> _errorIds = <String>{};

  @override
  void initState() {
    super.initState();
    _pairBySpanish = Map<String, String>.from(widget.payload);
    _spanishWords = _pairBySpanish.keys.toList()..shuffle();
    _englishWords = _pairBySpanish.values.toList()..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    if (_pairBySpanish.isEmpty) {
      return const Center(
        child: Text(
          'No hay pares disponibles.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionLabel(text: 'Español'),
                  const SizedBox(height: 12),
                  ..._spanishWords.map((word) {
                    final bool isMatched = _matchedIds.contains(_tileId('es', word));
                    final bool isSelected = _selectedSpanish == word;
                    final bool isError = _errorIds.contains(_tileId('es', word));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MatchButton(
                        text: word,
                        isSelected: isSelected,
                        isMatched: isMatched,
                        isError: isError,
                        onTap: isMatched ? null : () => _handleSpanishTap(word),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionLabel(text: 'Inglés'),
                  const SizedBox(height: 12),
                  ..._englishWords.map((word) {
                    final bool isMatched = _matchedIds.contains(_tileId('en', word));
                    final bool isSelected = _selectedEnglish == word;
                    final bool isError = _errorIds.contains(_tileId('en', word));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MatchButton(
                        text: word,
                        isSelected: isSelected,
                        isMatched: isMatched,
                        isError: isError,
                        onTap: isMatched ? null : () => _handleEnglishTap(word),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSpanishTap(String word) {
    if (_matchedIds.contains(_tileId('es', word))) {
      return;
    }

    setState(() {
      _selectedSpanish = word;
      _errorIds.clear();
    });

    HapticFeedback.selectionClick();
    _tryResolveMatch();
  }

  void _handleEnglishTap(String word) {
    if (_matchedIds.contains(_tileId('en', word))) {
      return;
    }

    setState(() {
      _selectedEnglish = word;
      _errorIds.clear();
    });

    HapticFeedback.selectionClick();
    _tryResolveMatch();
  }

  void _tryResolveMatch() {
    final String? selectedSpanish = _selectedSpanish;
    final String? selectedEnglish = _selectedEnglish;

    if (selectedSpanish == null || selectedEnglish == null) {
      return;
    }

    final String? expectedEnglish = _pairBySpanish[selectedSpanish];
    final bool isCorrect = expectedEnglish == selectedEnglish;

    if (isCorrect) {
      setState(() {
        _matchedIds
          ..add(_tileId('es', selectedSpanish))
          ..add(_tileId('en', selectedEnglish));
        _selectedSpanish = null;
        _selectedEnglish = null;
        _errorIds.clear();
      });

      HapticFeedback.lightImpact();

      if (_matchedIds.length == _pairBySpanish.length * 2) {
        widget.onAnswerSelected?.call('all_matched');
      }

      return;
    }

    setState(() {
      _errorIds
        ..clear()
        ..add(_tileId('es', selectedSpanish))
        ..add(_tileId('en', selectedEnglish));
      _selectedSpanish = null;
      _selectedEnglish = null;
    });

    HapticFeedback.mediumImpact();

    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorIds.clear();
      });
    });
  }

  String _tileId(String prefix, String word) => '$prefix:$word';
}

/// Etiqueta simple para cada columna.
class _SectionLabel extends StatelessWidget {
  /// Crea una etiqueta de columna.
  const _SectionLabel({required this.text});

  /// Texto visible.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Botón visual para una palabra del juego.
class _MatchButton extends StatelessWidget {
  /// Crea el botón de una palabra.
  const _MatchButton({
    required this.text,
    required this.isSelected,
    required this.isMatched,
    required this.isError,
    required this.onTap,
  });

  /// Texto visible del botón.
  final String text;

  /// Indica si la palabra está seleccionada.
  final bool isSelected;

  /// Indica si la palabra ya fue emparejada.
  final bool isMatched;

  /// Indica si la palabra está en estado de error.
  final bool isError;

  /// Acción al pulsar.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isMatched
        ? Colors.grey[200]!
        : isError
            ? const Color(0xFFFFE0E0)
            : isSelected
                ? const Color(0xFFD9ECFF)
                : const Color(0xFF1A2430);

    final Color borderColor = isMatched
        ? Colors.grey[300]!
        : isError
            ? const Color(0xFFFF6A6A)
            : isSelected
                ? const Color(0xFF7FCBFF)
                : const Color(0xFF31414D);

    final Color textColor = isMatched
        ? Colors.grey[600]!
        : isError
            ? const Color(0xFFB00020)
            : isSelected
                ? const Color(0xFF0B4E75)
                : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 86,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
