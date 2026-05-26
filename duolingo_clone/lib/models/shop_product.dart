import 'package:flutter/material.dart';

/// Modelo que representa un producto o tarjeta dentro de la tienda.
///
/// Este objeto permite renderizar ofertas, protectores de racha y promociones sin hardcodear
/// el contenido visual en la vista.
class ShopProduct {
  /// Crea un producto de tienda con metadata visual y comercial.
  const ShopProduct({
    required this.id,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    required this.accentColor,
    required this.priceLabel,
    required this.buttonLabel,
    this.isWideCard = false,
  });

  /// Identificador unico del producto.
  final String id;

  /// Seccion a la que pertenece el producto.
  final ShopSection section;

  /// Titulo principal del producto.
  final String title;

  /// Subtitulo descriptivo del producto.
  final String subtitle;

  /// Icono visual del producto.
  final IconData icon;

  /// Color de fondo del icono.
  final Color iconBackgroundColor;

  /// Color de acento para el titulo o datos destacados.
  final Color accentColor;

  /// Texto del precio o beneficio.
  final String priceLabel;

  /// Texto del boton de accion.
  final String buttonLabel;

  /// Indica si la tarjeta debe renderizarse en formato ancho.
  final bool isWideCard;
}

/// Secciones disponibles dentro de la tienda.
enum ShopSection {
  /// Ofertas especiales.
  specialOffers,

  /// Protectores de racha.
  streakProtectors,

  /// Codigo promocional.
  promoCode,
}