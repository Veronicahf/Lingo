import 'package:flutter/material.dart';

import '../models/shop_product.dart';

/// Repositorio simulado que entrega los productos de tienda desde datos locales.
///
/// Esta implementación mantiene la UI desacoplada de la fuente real de datos mientras se
/// desarrolla la integración con la API.
class MockShopRepository {
  /// Crea un repositorio mock de tienda.
  const MockShopRepository();

  /// Obtiene los productos de ofertas especiales.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/shop/special-offers');
  /// return (response.data as List).map((json) => ShopProduct.fromJson(json)).toList();
  /// ```
  Future<List<ShopProduct>> getSpecialOffers() async {
    return const [
      ShopProduct(
        id: 'widget_reward',
        section: ShopSection.specialOffers,
        title: 'Recompensa de widget',
        subtitle: 'Recibiste un Multiplicador de EXP por instalar el widget.',
        icon: Icons.emoji_events_rounded,
        iconBackgroundColor: Color(0xFF9E47C7),
        accentColor: Color(0xFF9FE2FF),
        priceLabel: 'RECIBE TU RECOMPENSA',
        buttonLabel: 'RECIBE TU RECOMPENSA',
      ),
    ];
  }

  /// Obtiene los protectores de racha disponibles.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/shop/streak-protectors');
  /// return (response.data as List).map((json) => ShopProduct.fromJson(json)).toList();
  /// ```
  Future<List<ShopProduct>> getStreakProtectors() async {
    return const [
      ShopProduct(
        id: 'streak_protector_1',
        section: ShopSection.streakProtectors,
        title: 'Protector de racha',
        subtitle: 'Protege tu racha si no practicas por un día. Equipa hasta 2 a la vez.',
        icon: Icons.ac_unit_rounded,
        iconBackgroundColor: Color(0xFF8CD9FF),
        accentColor: Color(0xFF8CD9FF),
        priceLabel: '200',
        buttonLabel: 'COMPRAR',
      ),
    ];
  }

  /// Obtiene la tarjeta de código promocional.
  ///
  /// TODO API:
  /// ```dart
  /// final response = await ApiClient.instance.get('/shop/promo-codes');
  /// return (response.data as List).map((json) => ShopProduct.fromJson(json)).toList();
  /// ```
  Future<List<ShopProduct>> getPromoCodeOffers() async {
    return const [
      ShopProduct(
        id: 'promo_code',
        section: ShopSection.promoCode,
        title: 'Ingresa un código promocional',
        subtitle: 'Ingresa un código y recibe recompensas',
        icon: Icons.confirmation_number_rounded,
        iconBackgroundColor: Color(0xFFFF5A5A),
        accentColor: Color(0xFF8CD9FF),
        priceLabel: '',
        buttonLabel: 'INGRESAR',
        isWideCard: true,
      ),
    ];
  }
}