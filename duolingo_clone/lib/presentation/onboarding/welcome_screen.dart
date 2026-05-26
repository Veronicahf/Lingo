import 'package:flutter/material.dart';

import '../layout/main_layout_screen.dart';
import '../widgets/mascot_animation_widget.dart';

/// Pantalla de bienvenida inicial que introduce el producto y dirige al usuario al flujo principal.
///
/// Esta vista actua como onboarding/splash funcional: muestra branding, opciones de acceso
/// y redirige con `pushReplacement` al layout principal para simular autenticacion inicial.
class WelcomeScreen extends StatelessWidget {
  /// Crea la pantalla inicial de onboarding.
  const WelcomeScreen({super.key});

  static const Color _backgroundColor = Color(0xFF101820);
  static const Color _primaryButtonColor = Color(0xFF66D94E);
  static const Color _primaryButtonShadowColor = Color(0xFF3E9F2D);
  static const Color _secondaryBorderColor = Color(0xFF4D5B67);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              const _WelcomeBrand(),
              const Spacer(flex: 2),
              _PrimaryStartButton(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const MainLayoutScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              const _SecondaryLoginButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloque visual de marca con mascota simulada e identidad textual de la app.
class _WelcomeBrand extends StatelessWidget {
  /// Construye la representacion principal de marca para onboarding.
  const _WelcomeBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
              Container(
                width: 220,
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF15212A),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF3E9F2D),
                      offset: Offset(0, 10),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const MascotAnimationWidget(
                  assetPath: 'assets/lottie/cat_idle.json',
                  width: 190,
                  height: 190,
                ),
              ),
              const SizedBox(height: 24),
        const Text(
          'LuaLingo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Boton primario para iniciar la experiencia principal de la aplicacion.
class _PrimaryStartButton extends StatelessWidget {
  /// Crea el boton principal con accion de continuidad.
  const _PrimaryStartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: WelcomeScreen._primaryButtonColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: WelcomeScreen._primaryButtonShadowColor,
              offset: Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Text(
          '¡EMPIEZA AHORA!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}

/// Boton secundario para usuarios existentes con estilo transparente y borde.
class _SecondaryLoginButton extends StatelessWidget {
  /// Crea el boton secundario de acceso para cuenta existente.
  const _SecondaryLoginButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WelcomeScreen._secondaryBorderColor, width: 3),
      ),
      child: const Text(
        'YA TENGO UNA CUENTA',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFC3CFD9),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}