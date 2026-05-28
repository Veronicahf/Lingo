import 'package:flutter/material.dart';

import '../../../core/audio_service.dart';

/// Widget de comprension auditiva con un boton principal de reproduccion y opciones de respuesta.
///
/// La actividad dibuja un boton grande con icono de bocina, seguido por una lista o cuadrícula de
/// opciones seleccionables. El widget mantiene un estado local sencillo para resaltar la opcion
/// escogida mientras la logica de validacion permanece en el motor de leccion.
class ListeningWidget extends StatefulWidget {
  /// Crea el widget de comprension auditiva con su payload de datos.
  const ListeningWidget({super.key, required this.payload, this.onAnswerSelected});

  /// Datos de la actividad, normalmente con `prompt` y `options`.
  final Map<String, dynamic> payload;

  /// Callback que reporta la opcion actualmente seleccionada.
  final ValueChanged<String>? onAnswerSelected;

  @override
  State<ListeningWidget> createState() => _ListeningWidgetState();
}

/// Estado interno de [ListeningWidget] que conserva la seleccion actual.
class _ListeningWidgetState extends State<ListeningWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final String title = _resolveTitle(widget.payload);
    final String subtitle = _resolveSubtitle(widget.payload);
    final List<String> options = _resolveOptions(widget.payload);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          _SpeakerButton(
            subtitle: subtitle,
            onTap: () {
              AudioService.instance.speak(subtitle);
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: options.isEmpty
                ? const Center(
                    child: Text(
                      'No hay opciones disponibles.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 112,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = _selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          widget.onAnswerSelected?.call(options[index]);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEAF6FF) : const Color(0xFF1A2430),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF7FCBFF) : const Color(0xFF31414D),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            options[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF0B4E75) : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _resolveTitle(Map<String, dynamic> payload) {
    final dynamic title = payload['title'] ?? payload['prompt'] ?? payload['instruction'];
    if (title is String && title.trim().isNotEmpty) {
      return title.trim();
    }

    return 'Escucha y selecciona la respuesta correcta';
  }

  String _resolveSubtitle(Map<String, dynamic> payload) {
    final dynamic subtitle = payload['subtitle'] ?? payload['audioText'] ?? payload['sentence'];
    if (subtitle is String && subtitle.trim().isNotEmpty) {
      return subtitle.trim();
    }

    return 'Toca el boton para escuchar el audio.';
  }

  List<String> _resolveOptions(Map<String, dynamic> payload) {
    final dynamic options = payload['options'] ?? payload['choices'];
    if (options is List) {
      return options.whereType<String>().toList(growable: false);
    }

    return const <String>[];
  }
}

/// Boton grande de reproduccion para la actividad auditiva.
class _SpeakerButton extends StatelessWidget {
  /// Crea el boton de bocina grande.
  const _SpeakerButton({required this.subtitle, required this.onTap});

  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF59C8FF),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1B8FC2),
              offset: Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up_rounded, color: Color(0xFF10212B), size: 78),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF10212B),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}