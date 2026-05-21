import 'package:flutter/material.dart';

class ActiveLessonScreen extends StatelessWidget {
  const ActiveLessonScreen({
    super.key,
    this.progress = 0.28,
    this.child,
    this.onCheck,
  });

  final double progress;
  final Widget? child;
  final VoidCallback? onCheck;

  static const Color _backgroundColor = Color(0xFF101820);
  static const Color _progressColor = Color(0xFF9EEB2A);
  static const Color _progressTrack = Color(0xFF2B3840);
  static const Color _buttonColor = Color(0xFF8CE317);
  static const Color _buttonShadow = Color(0xFF5FA10F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.close_rounded, color: Color(0xFF9AA7B1), size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: _progressTrack,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _progressColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: GestureDetector(
            onTap: onCheck ?? () {},
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: _buttonColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _buttonShadow.withOpacity(0.85),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'COMPROBAR',
                style: TextStyle(
                  color: Color(0xFF09220A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
