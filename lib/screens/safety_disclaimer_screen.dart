import 'package:flutter/material.dart';
import 'hud_home_screen.dart';

/// Full-screen safety disclaimer overlay that requires explicit acknowledgment
/// before allowing the rider into the main cockpit dashboard.
class SafetyDisclaimerScreen extends StatelessWidget {
  final VoidCallback? onAccepted;
  final Color accentColor;

  const SafetyDisclaimerScreen({
    super.key,
    this.onAccepted,
    this.accentColor = const Color(0xFF4C8DF6),
  });

  void _handleAccept(BuildContext context) {
    if (onAccepted != null) {
      onAccepted!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HudHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF131922),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Safety Shield Header Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.28),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Title
                  const Text(
                    'RIDER SAFETY NOTICE',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Exact Disclaimer Body Text
                  const Text(
                    'Safe use of this device is the rider’s responsibility. Only interact with the device when it is safe to do so, and never while maneuvering or actively controlling the vehicle. Stay alert, remain aware of your surroundings, follow all applicable traffic laws, and always wear a helmet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 13.5,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFCAD4E0),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // 4. "I Understand" Button
                  SizedBox(
                    width: 220,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _handleAccept(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'I Understand',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

