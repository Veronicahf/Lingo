import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/onboarding_question.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../layout/main_layout_screen.dart';
import '../widgets/mascot_animation_widget.dart';

/// Pantalla que ejecuta el wizard de onboarding secuencial con 8 preguntas.
class OnboardingWizardScreen extends StatefulWidget {
  /// Crea el wizard de onboarding.
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  late final OnboardingViewModel _viewModel;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewModel();
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

  void _previousStep() {
    if (_viewModel.currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    _viewModel.previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF101820),
        body: Consumer<OnboardingViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _OnboardingTopBar(
                  onBackPressed: _previousStep,
                  progress: vm.progress,
                  currentStep: vm.currentStep,
                  totalSteps: vm.totalSteps,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _OnboardingQuestionContent(
                      key: ValueKey<int>(vm.currentStep),
                      question: vm.currentQuestion,
                      selectedAnswer: vm.currentAnswer,
                      selectedAnswers: vm.selectedAnswers,
                      isLoading: vm.isRegistering,
                      onOptionSelected: (option) async {
                        await vm.selectOption(option);
                      },
                      onContinuePressed: vm.continueStep,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Barra superior del onboarding con flecha de regreso y progreso.
class _OnboardingTopBar extends StatelessWidget {
  /// Crea la barra superior del wizard.
  const _OnboardingTopBar({
    required this.onBackPressed,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
  });

  final VoidCallback onBackPressed;
  final double progress;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF55C7FF)),
                onPressed: onBackPressed,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFF2B3138),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF55C7FF)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${currentStep + 1}/$totalSteps',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenido de una pregunta del onboarding con animación y botones de respuesta.
class _OnboardingQuestionContent extends StatelessWidget {
  /// Crea la vista de la pregunta actual.
  const _OnboardingQuestionContent({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.selectedAnswers,
    required this.isLoading,
    required this.onOptionSelected,
    required this.onContinuePressed,
  });

  final OnboardingQuestion question;
  final String? selectedAnswer;
  final List<String> selectedAnswers;
  final bool isLoading;
  final ValueChanged<String> onOptionSelected;
  final Future<void> Function() onContinuePressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MascotAnimationWidget(
                    assetPath: question.animationPath,
                    width: 220,
                    height: 220,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18222B),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      question.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: question.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        final bool isSelected = question.allowMultipleSelection
                            ? selectedAnswers.contains(option.text)
                            : option.text == selectedAnswer;
                        final bool isEnabled = option.isEnabled;

                        return Opacity(
                          opacity: isEnabled ? 1.0 : 0.42,
                          child: IgnorePointer(
                            ignoring: !isEnabled,
                            child: GestureDetector(
                              onTap: isLoading ? null : () => onOptionSelected(option.text),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF203544) : const Color(0xFF18222B),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF55C7FF) : const Color(0xFF5A646D),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  option.text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF9FE33A) : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (question.allowMultipleSelection) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: isLoading ? null : () => onContinuePressed(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
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
                            'CONTINUAR',
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
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF55C7FF)),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
