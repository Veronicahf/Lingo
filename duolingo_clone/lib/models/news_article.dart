import 'package:flutter/material.dart';

/// Modelo que representa una tarjeta de novedad dentro del feed de la aplicacion.
///
/// Esta entidad concentra el contenido, el estilo visual y el icono de cada articulo para que
/// la vista pueda renderizarlo desde datos estructurados y no desde widgets quemados.
class NewsArticle {
  /// Crea un articulo de novedad con su contenido y estilo visual.
  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.backgroundColor,
    required this.iconData,
    required this.likesCount,
    required this.isLikedByMe,
  });

  /// Identificador unico del articulo.
  final String id;

  /// Titulo principal de la tarjeta.
  final String title;

  /// Descripcion o subtitulo del articulo.
  final String description;

  /// Texto del boton de accion.
  final String buttonText;

  /// Color de fondo expresado como entero ARGB.
  final int backgroundColor;

  /// Icono asociado al articulo.
  final IconData iconData;

  /// Cantidad de likes o reacciones visibles en el feed.
  final int likesCount;

  /// Indica si el usuario actual ya reacciono a esta publicacion.
  final bool isLikedByMe;
}