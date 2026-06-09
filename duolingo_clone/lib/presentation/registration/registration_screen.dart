import 'package:flutter/material.dart';

import '../../core/mock_database.dart';
import '../widgets/mascot_animation_widget.dart';
import 'registration_viewmodel.dart';

/// Pantalla de registro obligatorio que aparece al completar la lección 2
/// o al intentar acceder a Ranking/Perfil sin haber finalizado el perfil.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final RegistrationViewModel _viewModel = RegistrationViewModel();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF101820),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF55C7FF)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MascotAnimationWidget.fromEmotion(
                    emotion: 'happy',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completa tu perfil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tus datos para guardar tu progreso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    label: 'Nombre',
                    hint: 'Tu nombre',
                    icon: Icons.person_rounded,
                    controller: _nameController,
                    errorText: _viewModel.nameError,
                    onChanged: _viewModel.setName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Correo electrónico',
                    hint: 'correo@ejemplo.com',
                    icon: Icons.email_rounded,
                    controller: _emailController,
                    errorText: _viewModel.emailError,
                    onChanged: _viewModel.setEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Contraseña',
                    hint: 'Mínimo 6 caracteres',
                    icon: Icons.lock_rounded,
                    controller: _passwordController,
                    errorText: _viewModel.passwordError,
                    onChanged: _viewModel.setPassword,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Confirmar contraseña',
                    hint: 'Repite tu contraseña',
                    icon: Icons.lock_rounded,
                    controller: _confirmPasswordController,
                    errorText: null,
                    onChanged: _viewModel.setConfirmPassword,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),
                  _buildRegisterButton(context),
                  const SizedBox(height: 16),
                  _buildSocialLoginSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? errorText,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AA7B1),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF55C7FF), size: 22),
            errorText: errorText,
            errorStyle: const TextStyle(
              color: Color(0xFFFF3B3B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: const Color(0xFF18222B),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFFF3B3B)
                    : const Color(0xFF2B3943),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF2B3943),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF55C7FF),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF55C7FF)),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        final User? user = await _viewModel.submitRegistration();
        if (user != null && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _viewModel.isValid
              ? const Color(0xFF55C7FF)
              : const Color(0xFF2B3943),
          borderRadius: BorderRadius.circular(22),
          boxShadow: _viewModel.isValid
              ? const [
                  BoxShadow(
                    color: Color(0xFF2D7C9A),
                    offset: Offset(0, 8),
                    blurRadius: 0,
                  ),
                ]
              : null,
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
    );
  }

  Widget _buildSocialLoginSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF2B3943))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continúa con',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF2B3943))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
                onTap: () => _handleSocialLogin(context, 'Google'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                onTap: () => _handleSocialLogin(context, 'Facebook'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF18222B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2B3943), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF55C7FF), size: 28),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(BuildContext context, String provider) async {
    _nameController.text = 'Usuario de $provider';
    _viewModel.setName('Usuario de $provider');
    _emailController.text = '${provider.toLowerCase()}@lingo.local';
    _viewModel.setEmail('${provider.toLowerCase()}@lingo.local');
    _viewModel.setPassword('social123');
    _viewModel.setConfirmPassword('social123');
    _passwordController.text = 'social123';
    _confirmPasswordController.text = 'social123';

    final User? user = await _viewModel.submitRegistration();
    if (user != null && context.mounted) {
      Navigator.pop(context);
    }
  }
}
