import 'package:flutter/material.dart';

import '../../core/under_construction_command.dart';
import '../../models/shop_product.dart';
import '../../viewmodels/shop_viewmodel.dart';

/// Pantalla completa de la tienda de la aplicación.
///
/// Esta pantalla presenta ofertas especiales, protectores de racha y código promocional usando
/// un ViewModel mock para conservar la separación entre UI y datos.
class ShopScreen extends StatefulWidget {
  /// Crea la pantalla de tienda.
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

/// Estado interno de [ShopScreen] que carga el ViewModel y libera sus recursos.
class _ShopScreenState extends State<ShopScreen> {
  late final ShopViewModel _viewModel = ShopViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadShopData();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF101820),
          appBar: _ShopTopBar(
            gemsLabel: _viewModel.gemsTotalLabel,
            onClose: () => Navigator.of(context).pop(),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShopSectionHeader(text: _viewModel.specialOffersTitle),
                const SizedBox(height: 14),
                ..._viewModel.specialOffers.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ShopCard(product: product, dense: false),
                  ),
                ),
                const SizedBox(height: 4),
                _ShopSectionHeader(text: _viewModel.streakProtectorsTitle),
                const SizedBox(height: 8),
                Text(
                  _viewModel.streakProtectorsSubtitle,
                  style: const TextStyle(
                    color: Color(0xFF9AA7B1),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                ..._viewModel.streakProtectors.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ShopCard(product: product, dense: false),
                  ),
                ),
                const SizedBox(height: 4),
                _ShopSectionHeader(text: _viewModel.promoCodeTitle),
                const SizedBox(height: 14),
                ..._viewModel.promoCodeOffers.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ShopCard(product: product, dense: true),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Barra superior personalizada de la tienda.
class _ShopTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Crea el encabezado con botón de cierre, titulo y saldo de gemas.
  const _ShopTopBar({
    required this.gemsLabel,
    required this.onClose,
  });

  final String gemsLabel;
  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF101820),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: 86,
      title: const Text(
        'Tienda',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      leading: IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 34),
      ),
      leadingWidth: 58,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.diamond_rounded, color: Color(0xFF48B9FF), size: 26),
              const SizedBox(width: 8),
              Text(
                gemsLabel,
                style: const TextStyle(
                  color: Color(0xFF48B9FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Encabezado visual de cada seccion de la tienda.
class _ShopSectionHeader extends StatelessWidget {
  /// Crea un encabezado de seccion.
  const _ShopSectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

/// Tarjeta reutilizable para representar un producto en la tienda.
class _ShopCard extends StatelessWidget {
  /// Crea la tarjeta a partir del modelo de producto.
  const _ShopCard({
    required this.product,
    required this.dense,
  });

  final ShopProduct product;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => const UnderConstructionCommand().execute(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF18222B),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF33414A), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: dense ? 84 : 92,
              height: dense ? 84 : 92,
              decoration: BoxDecoration(
                color: product.iconBackgroundColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(product.icon, color: Colors.white, size: dense ? 44 : 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      color: product.accentColor,
                      fontSize: dense ? 20 : 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (product.priceLabel.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.diamond_rounded, color: Color(0xFF48B9FF), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          product.priceLabel,
                          style: const TextStyle(
                            color: Color(0xFF48B9FF),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  if (product.priceLabel.isNotEmpty) const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => const UnderConstructionCommand().execute(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF55C7FF),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1D7EAE).withValues(alpha: 0.55),
                            offset: const Offset(0, 7),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        product.buttonLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF101820),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}