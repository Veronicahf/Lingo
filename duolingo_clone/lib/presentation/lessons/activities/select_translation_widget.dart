import 'package:flutter/material.dart';

/// Widget que permite seleccionar una traduccion correcta desde una columna de opciones.
///
/// Recibe la lista de respuestas disponibles desde el payload del motor de leccion y pinta
/// el estado seleccionado con un borde azul claro y un fondo azul muy tenue.
class SelectTranslationWidget extends StatefulWidget {
  /// Crea el widget de seleccion de traduccion con sus opciones disponibles.
  const SelectTranslationWidget({super.key, required this.payload, this.onAnswerSelected});

  /// Datos de la actividad, incluyendo el texto principal y las opciones disponibles.
  final Map<String, dynamic> payload;

  /// Callback que reporta la respuesta actualmente seleccionada.
  final ValueChanged<String>? onAnswerSelected;

  @override
  State<SelectTranslationWidget> createState() => _SelectTranslationWidgetState();
}

/// Estado interno de [SelectTranslationWidget] que conserva la opcion seleccionada.
class _SelectTranslationWidgetState extends State<SelectTranslationWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final List<String> options = _resolveOptions();
    final String promptText = _resolvePromptText();
    final String textToTranslate = _resolveTextToTranslate();

    if (options.isEmpty) {
      return const Center(
        child: Text(
          'No hay opciones disponibles.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (textToTranslate.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2E3A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4A6278),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      textToTranslate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            Text(
              promptText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            ...List<Widget>.generate(options.length, (index) {
              final bool isSelected = _selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                      widget.onAnswerSelected?.call(options[index]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEAF6FF) : const Color(0xFF1A2430),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF7FCBFF) : const Color(0xFF31414D),
                        width: 2,
                      ),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF0B4E75) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      child: Text(options[index], textAlign: TextAlign.center),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _resolvePromptText() {
    final dynamic title = widget.payload['title'] ?? widget.payload['prompt'] ?? widget.payload['instruction'];
    if (title is String && title.trim().isNotEmpty) {
      return title.trim();
    }

    return 'Selecciona la traducción correcta.';
  }

  String _resolveTextToTranslate() {
    final dynamic text = widget.payload['textToTranslate'];
    if (text is String && text.trim().isNotEmpty) {
      return text.trim();
    }

    return '';
  }

  List<String> _resolveOptions() {
    final dynamic options = widget.payload['options'] ?? widget.payload['choices'];
    if (options is List) {
      return options.whereType<String>().toList(growable: false);
    }

    return const <String>[];
  }
}