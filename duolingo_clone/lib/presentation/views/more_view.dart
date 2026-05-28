import 'package:flutter/material.dart';

import '../../models/more_option.dart';
import '../../viewmodels/more_viewmodel.dart';
import '../more/practice_center_screen.dart';
import '../more/sounds_screen.dart';
import '../more/video_call_screen.dart';

/// Pantalla de opciones adicionales que agrupa accesos a funciones secundarias de la app.
///
/// Esta vista escucha al [MoreViewModel] y construye las tarjetas desde una lista estructurada,
/// delegando la navegación a rutas concretas según el identificador de cada opcion.
class MoreView extends StatefulWidget {
  /// Crea la pantalla "Más".
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

/// Estado interno de [MoreView] que carga y libera la ViewModel.
class _MoreViewState extends State<MoreView> {
  late final MoreViewModel _viewModel = MoreViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadOptions();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF101820),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          const Text(
            'Más',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              final options = _viewModel.options;

              if (options.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _MoreOptionCard(
                    option: option,
                    onTap: () => _navigateByOptionId(context, option.id),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateByOptionId(BuildContext context, String optionId) {
    switch (optionId) {
      case 'sounds':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SoundsScreen()),
        );
        break;
      case 'practice_center':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PracticeCenterScreen()),
        );
        break;
      case 'video_call':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VideoCallScreen()),
        );
        break;
      default:
        break;
    }
  }
}

/// Tarjeta reutilizable para una opcion del menu "Más".
class _MoreOptionCard extends StatelessWidget {
  /// Crea la tarjeta a partir del modelo [MoreOption].
  const _MoreOptionCard({
    required this.option,
    required this.onTap,
  });

  final MoreOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A272F),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
          border: Border.all(color: const Color(0xFF33414A), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: option.iconBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(option.icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      color: option.accentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9AA7B1),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA7B1), size: 30),
          ],
        ),
      ),
    );
  }
}
