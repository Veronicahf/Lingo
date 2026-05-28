import 'package:flutter/material.dart';

/// Widget reutilizable para completar espacios en blanco con botones de opcion.
///
/// La actividad recibe la oracion dividida en partes y un conjunto de opciones. Al tocar una
/// opcion, esa palabra se inserta en el hueco superior y el boton pasa a un estado seleccionado.
/// Esta misma vista se usa tanto para ejercicios de espacio en blanco como para dialogos con una
/// pequena variacion visual en la parte superior.
class FillBlankWidget extends StatefulWidget {
  /// Crea el widget de completar espacios en blanco.
  const FillBlankWidget({
    super.key,
    required this.payload,
    this.isDialogStyle = false,
    this.onAnswerSelected,
  });

  /// Datos de la actividad, normalmente con `sentenceParts` y `options`.
  final Map<String, dynamic> payload;

  /// Indica si la actividad debe verse como un dialogo en lugar de una frase simple.
  final bool isDialogStyle;

  /// Callback que reporta la frase completa cuando el usuario selecciona una opcion.
  final ValueChanged<String>? onAnswerSelected;

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

/// Estado interno de [FillBlankWidget] que administra la opcion seleccionada.
class _FillBlankWidgetState extends State<FillBlankWidget> {
  late final List<String> _options;
  String? _selectedWord;

  @override
  void initState() {
    super.initState();
    _options = _buildOptions(widget.payload);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sentenceParts = _buildSentenceParts(widget.payload);
    final String beforeBlank = sentenceParts.isNotEmpty ? sentenceParts.first : '';
    final String afterBlank = sentenceParts.length > 1 ? sentenceParts.last : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isDialogStyle)
            _DialogHeader(
              title: _resolveTitle(widget.payload),
              subtitle: _resolveSubtitle(widget.payload),
            )
          else
            Text(
              _resolveTitle(widget.payload),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF111A22),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF31414D), width: 2),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 10,
              children: [
                if (beforeBlank.isNotEmpty)
                  Text(
                    beforeBlank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                _BlankSlot(
                  text: _selectedWord,
                  isFilled: _selectedWord != null,
                  isDialogStyle: widget.isDialogStyle,
                ),
                if (afterBlank.isNotEmpty)
                  Text(
                    afterBlank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final word in _options)
                _OptionChip(
                  label: word,
                  selected: _selectedWord == word,
                  onTap: () {
                    setState(() {
                      _selectedWord = word;
                    });
                    widget.onAnswerSelected?.call(_buildCurrentSentence(word));
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _buildSentenceParts(Map<String, dynamic> payload) {
    final dynamic sentenceParts = payload['sentenceParts'] ?? payload['parts'];
    if (sentenceParts is List) {
      return sentenceParts.whereType<String>().toList(growable: false);
    }

    final String sentence = _resolveTitle(payload);
    return <String>[sentence, ''];
  }

  List<String> _buildOptions(Map<String, dynamic> payload) {
    final dynamic options = payload['options'] ?? payload['choices'];
    if (options is List) {
      return options.whereType<String>().toList(growable: false);
    }

    return const <String>[];
  }

  String _resolveTitle(Map<String, dynamic> payload) {
    final dynamic title = payload['title'] ?? payload['prompt'] ?? payload['sentence'];
    if (title is String && title.trim().isNotEmpty) {
      return title.trim();
    }

    return widget.isDialogStyle ? 'Completa el diálogo' : 'Completa el espacio en blanco';
  }

  String _resolveSubtitle(Map<String, dynamic> payload) {
    final dynamic subtitle = payload['subtitle'] ?? payload['dialogPrompt'];
    if (subtitle is String && subtitle.trim().isNotEmpty) {
      return subtitle.trim();
    }

    return 'Elige la palabra correcta para completar la respuesta.';
  }

  String _buildCurrentSentence(String selectedWord) {
    final List<String> sentenceParts = _buildSentenceParts(widget.payload);
    final String beforeBlank = sentenceParts.isNotEmpty ? sentenceParts.first : '';
    final String afterBlank = sentenceParts.length > 1 ? sentenceParts.last : '';
    return '$beforeBlank$selectedWord$afterBlank'.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

/// Encabezado simple para dar variacion visual al modo dialogo.
class _DialogHeader extends StatelessWidget {
  /// Crea el encabezado del modo dialogo.
  const _DialogHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF9AA7B1),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Caja que representa el espacio vacio o ya rellenado.
class _BlankSlot extends StatelessWidget {
  /// Crea el slot del espacio vacio.
  const _BlankSlot({required this.text, required this.isFilled, required this.isDialogStyle});

  final String? text;
  final bool isFilled;
  final bool isDialogStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(minWidth: 110, minHeight: 52),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFFEAF6FF) : const Color(0xFF18222C),
        borderRadius: BorderRadius.circular(isDialogStyle ? 18 : 14),
        border: Border.all(
          color: isFilled ? const Color(0xFF7FCBFF) : const Color(0xFF364955),
          width: 2,
        ),
      ),
      child: Text(
        text ?? '____',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isFilled ? const Color(0xFF0B4E75) : const Color(0xFF70828F),
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Boton de opcion reutilizable para el banco de palabras.
class _OptionChip extends StatelessWidget {
  /// Crea un chip de opcion.
  const _OptionChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF6FF) : const Color(0xFF1A2430),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF7FCBFF) : const Color(0xFF32424F),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF0B4E75) : Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}