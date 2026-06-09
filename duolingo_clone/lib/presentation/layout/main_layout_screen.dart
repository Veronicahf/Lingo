import 'package:flutter/material.dart';

import '../../core/service_locator.dart';
import '../registration/registration_screen.dart';
import '../views/challenges_view.dart';
import '../views/home_view.dart';
import '../views/more_view.dart';
import '../views/news_view.dart';
import '../views/profile_view.dart';
import '../views/ranking_view.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  static const List<Widget> _views = <Widget>[
    HomeView(),
    ChallengesView(),
    RankingView(),
    NewsView(),
    ProfileView(),
    MoreView(),
  ];

  void _onItemSelected(int index) {
    if (index == 5) {
      _showMoreOptionsBottomSheet();
      return;
    }

    // Gate de registro: Ranking (2) y Perfil (4) requieren registro completo
    if (ServiceLocator.registrationRequired && (index == 2 || index == 4)) {
      _showRegistrationGate();
      return;
    }

    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showRegistrationGate() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101820),
      barrierColor: Colors.black.withValues(alpha: 0.72),
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) {
        return _RegistrationGateSheet(
          onRegister: () {
            Navigator.pop(context);
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const RegistrationScreen(),
              ),
            );
          },
        );
      },
    );
  }

  void _showMoreOptionsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101820),
      barrierColor: Colors.black.withValues(alpha: 0.72),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) {
        return const MoreView();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _views,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
        onMorePressed: _showMoreOptionsBottomSheet,
      ),
    );
  }
}

/// BottomSheet que informa al usuario que debe registrarse para acceder.
class _RegistrationGateSheet extends StatelessWidget {
  /// Crea la hoja de registro obligatorio.
  const _RegistrationGateSheet({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF24313A),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: Color(0xFF55C7FF),
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Completa tu registro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Para acceder a esta sección necesitas crear una cuenta con tu nombre, correo y contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRegister,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF55C7FF),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF2D7C9A),
                      offset: Offset(0, 8),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'CREAR CUENTA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18222B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF2B3943),
                    width: 2,
                  ),
                ),
                child: const Text(
                  'AHORA NO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
