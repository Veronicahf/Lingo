import 'package:flutter/material.dart';

/// Modelo que representa una opcion del menu "Más" de la aplicación.
///
/// Esta entidad centraliza el contenido y el estilo visual de cada acceso para que la vista
/// pueda iterar sobre una lista de datos y decidir la navegación por identificador.
class MoreOption {
  /// Crea una opcion del menu con su estilo y metadata.
  const MoreOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.iconBackground,
  });

  /// Identificador unico de la opcion.
  final String id;

  /// Titulo visible de la opcion.
  final String title;

  /// Subtitulo descriptivo de la opcion.
  final String subtitle;

  /// Icono que representa visualmente la opcion.
  final IconData icon;

  /// Color de acento para el titulo.
  final Color accentColor;

  /// Color de fondo del icono.
  final Color iconBackground;
}
