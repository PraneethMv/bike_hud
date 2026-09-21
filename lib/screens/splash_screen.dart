import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/rev_hud_logo.dart';
import 'safety_disclaimer_screen.dart';

/// Minimalist startup splash screen for Rev HUD.
/// Follows Material 3 dark cockpit guidelines with solid black background
/// and clean typography as specified in the design mockup.
class SplashScreen extends StatefulWidget {
  final String userName;
  final Duration duration;
  final VoidCallback? onFinished;
  final Color accentColor;

  const SplashScreen({
    super.key,
    this.userName = 'Praneeth',
    this.duration = const Duration(milliseconds: 2600),
    this.onFinished,
    this.accentColor = const Color(0xFF4C8DF6), // Material 3 Accent Blue
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _progressAnimation;

  Timer? _navigationTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.95, curve: Curves.easeInOutCubic),
    );

    _controller.forward();

    _navigationTimer = Timer(widget.duration + const Duration(milliseconds: 200), () {
      _finishStartup();
    });
  }

  void _finishStartup() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _navigationTimer?.cancel();

    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            SafetyDisclaimerScreen(accentColor: widget.accentColor),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            _finishStartup();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finishStartup,
          child: Stack(
            children: [
              // 1. Subtle Minimalist Ambient Wave Curves at the bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 220,
                child: CustomPaint(
                  painter: _MinimalistWavesPainter(),
                ),
              ),

              // 2. Centered Logo, Greeting, and Progress Bar
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Vector Speedometer & RevHUD Logo
                      RevHudLogo(
                        iconSize: 76,
                        fontSize: 50,
                        primaryColor: widget.accentColor,
                      ),

                      const SizedBox(height: 28),

                      // Minimalist Welcome text (clean, no container)
                      Text(
                        'Welcome, ${widget.userName}',
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 21,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFF1F5F9),
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Minimalist Capsule Progress Bar
                      Container(
                        width: 350,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2530),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            final progress = _progressAnimation.value.clamp(0.0, 1.0);
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.accentColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Initializing text
                      const Text(
                        'Initializing...',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Very Bottom Footer: RevOS - v0.1a
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Text(
                    'RevHUD - v0.1.0',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B).withValues(alpha: 0.75),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws soft, elegant dark waves along the bottom matching the mockup image.
class _MinimalistWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Back wave (deep subtle charcoal navy)
    final backWavePaint = Paint()
      ..color = const Color(0xFF0F1520).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.25, h * 0.25, w * 0.55, h * 0.65)
      ..quadraticBezierTo(w * 0.80, h * 0.95, w, h * 0.45)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backPath, backWavePaint);

    // Front wave (soft deep navy)
    final frontWavePaint = Paint()
      ..color = const Color(0xFF131B28).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final frontPath = Path()
      ..moveTo(0, h * 0.80)
      ..quadraticBezierTo(w * 0.35, h * 0.40, w * 0.70, h * 0.75)
      ..quadraticBezierTo(w * 0.88, h * 0.92, w, h * 0.65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(frontPath, frontWavePaint);
  }

  @override
  bool shouldRepaint(covariant _MinimalistWavesPainter oldDelegate) => false;
}
