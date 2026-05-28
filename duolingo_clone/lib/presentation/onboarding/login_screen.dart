import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/service_locator.dart';
import '../../core/under_construction_command.dart';
import '../../presentation/layout/main_layout_screen.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../widgets/mascot_animation_widget.dart';

/// Pantalla de acceso que conecta el formulario con el login simulado.
class LoginScreen extends StatefulWidget {
  /// Crea la pantalla de inicio de sesion.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginViewModel _viewModel;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(userRepository: ServiceLocator.userRepository);
    _viewModel.addListener(_handleViewModelChanges);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChanges);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleViewModelChanges() {
    if (!mounted) {
      return;
    }

    if (_viewModel.isSuccess && !_didNavigate) {
      _didNavigate = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (_) => const MainLayoutScreen()),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        appBar: _LoginTopBar(),
        backgroundColor: const Color(0xFF101820),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: MascotAnimationWidget(
                    assetPath: 'assets/lottie/Cat_typing.json',
                    width: 180,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                const _LoginHeader(),
                const SizedBox(height: 24),
                const _EmailTextField(),
                const SizedBox(height: 16),
                const _PasswordTextField(),
                const SizedBox(height: 10),
                const _ForgotPasswordButton(),
                const SizedBox(height: 20),
                const _LoginButton(),
                const SizedBox(height: 12),
                const _LoginFeedback(),
                const SizedBox(height: 28),
                const _DividerWithText(),
                const SizedBox(height: 20),
                const _SocialButtonsRow(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Encabezado textual que guía al usuario en el acceso.
class _LoginHeader extends StatelessWidget {
  /// Crea el encabezado del formulario de acceso.
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            const Text(
              'Bienvenido de vuelta',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vm.isLoading ? 'Verificando tu sesión...' : 'Ingresa para continuar tu progreso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Barra superior del login con navegación de regreso.
class _LoginTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Crea la barra superior del login.
  const _LoginTopBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF101820),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF55C7FF)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Ingresa tus datos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }
}

/// Campo de texto para capturar el correo del usuario.
class _EmailTextField extends StatelessWidget {
  /// Crea el campo de correo ligado al ViewModel.
  const _EmailTextField();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return TextFormField(
          onChanged: vm.setEmail,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Correo electrónico, teléfono o usuario',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: const Color(0xFF18222B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2B3138),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2B3138),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF55C7FF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        );
      },
    );
  }
}

/// Campo de texto para capturar la contraseña del usuario.
class _PasswordTextField extends StatelessWidget {
  /// Crea el campo de contraseña ligado al ViewModel.
  const _PasswordTextField();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return TextFormField(
          onChanged: vm.setPassword,
          obscureText: !vm.showPassword,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Contraseña',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: const Color(0xFF18222B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2B3138),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2B3138),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF55C7FF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: GestureDetector(
              onTap: vm.togglePasswordVisibility,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  vm.showPassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF55C7FF),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Boton de ayuda para recuperar la contraseña.
class _ForgotPasswordButton extends StatelessWidget {
  /// Crea el acceso a recuperación aún no implementada.
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          UnderConstructionCommand().execute(context);
        },
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Color(0xFF55C7FF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Boton principal que ejecuta el login contra el ViewModel.
class _LoginButton extends StatelessWidget {
  /// Crea el boton de ingreso ligado al estado del formulario.
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return IgnorePointer(
          ignoring: vm.isLoading || !vm.isFormValid,
          child: GestureDetector(
            onTap: () => vm.login(vm.email, vm.password),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: vm.isFormValid
                    ? const Color(0xFF66D94E)
                    : const Color(0xFF66D94E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                boxShadow: vm.isFormValid
                    ? [
                        const BoxShadow(
                          color: Color(0xFF000000),
                          offset: Offset(0, 8),
                          blurRadius: 0,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: vm.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text(
                        'INGRESAR',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Mensaje visual para errores o estados de carga del login.
class _LoginFeedback extends StatelessWidget {
  /// Crea el area de feedback conectada al ViewModel.
  const _LoginFeedback();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        final String? message = vm.errorMessage;

        if (message == null && !vm.isLoading) {
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            key: ValueKey<String>(message ?? 'loading'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: message == null ? const Color(0xFF1B2A34) : const Color(0xFF3B1E23),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: message == null ? const Color(0xFF55C7FF).withValues(alpha: 0.35) : const Color(0xFFF26D72),
              ),
            ),
            child: Text(
              message ?? 'Validando credenciales...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Separador visual entre login directo y acceso social.
class _DividerWithText extends StatelessWidget {
  /// Crea un divisor centrado con la letra O.
  const _DividerWithText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

/// Fila de botones sociales para login alternativo simulado.
class _SocialButtonsRow extends StatelessWidget {
  /// Crea la fila con accesos a redes sociales.
  const _SocialButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FacebookButton(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GoogleButton(),
        ),
      ],
    );
  }
}

/// Boton social de Facebook que por ahora solo muestra el mensaje de construccion.
class _FacebookButton extends StatelessWidget {
  /// Crea el boton de Facebook.
  const _FacebookButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UnderConstructionCommand().execute(context);
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1877F2),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.facebook_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'FACEBOOK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Boton social de Google que por ahora solo muestra el mensaje de construccion.
class _GoogleButton extends StatelessWidget {
  /// Crea el boton de Google.
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UnderConstructionCommand().execute(context);
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF18222B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.language,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'GOOGLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
