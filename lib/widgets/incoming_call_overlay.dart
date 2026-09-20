import 'package:flutter/material.dart';
import '../models/call_state.dart';
import '../models/hud_theme.dart';

class IncomingCallBanner extends StatelessWidget {
  final CallState callState;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final HudTheme theme;

  const IncomingCallBanner({
    super.key,
    required this.callState,
    required this.onAccept,
    required this.onReject,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (!callState.isIncoming) return const SizedBox.shrink();

    return Positioned(
      top: 10,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.card.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00E5A0).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF00E5A0).withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Pulsing incoming call icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5A0).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFF00E5A0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              // Caller Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          callState.callerName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.text,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5A0).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'INCOMING CALL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E5A0),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (callState.callerNumber.isNotEmpty)
                      Text(
                        callState.callerNumber,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textDim,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                  ],
                ),
              ),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reject / Decline Button
                  FilledButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.call_end_rounded, size: 16),
                    label: const Text(
                      'Decline',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Accept / Answer Button
                  FilledButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: const Text(
                      'Answer',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5A0),
                      foregroundColor: const Color(0xFF052B20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Backward compatibility typedef
typedef IncomingCallOverlay = IncomingCallBanner;
