import 'package:flutter/material.dart';
import '../models/navigation_state.dart';
import '../models/hud_theme.dart';

class NavigationPanel extends StatefulWidget {
  final NavigationState navigationState;
  final HudTheme theme;

  const NavigationPanel({
    super.key,
    required this.navigationState,
    required this.theme,
  });

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  double _zoom = 1.0;
  bool _isMuted = false;
  bool _is3d = true;
  String _selectedPoi = 'Shell Fuel Station';

  final List<_PoiItem> _pois = const [
    _PoiItem(name: 'Shell Fuel Station', dist: '1.2 km', eta: '4 min', icon: Icons.local_gas_station_rounded),
    _PoiItem(name: 'EV Fast Charger', dist: '2.8 km', eta: '7 min', icon: Icons.bolt_rounded),
    _PoiItem(name: 'Cafe & Rider Rest Stop', dist: '3.5 km', eta: '9 min', icon: Icons.coffee_rounded),
    _PoiItem(name: 'Two-Wheeler Care', dist: '4.1 km', eta: '11 min', icon: Icons.build_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: widget.theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.theme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // 1. Vector Map Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: _M3MapCanvasPainter(
                  theme: widget.theme,
                  zoom: _zoom,
                  is3d: _is3d,
                ),
              ),
            ),

            // 2. Top-Left: Floating Turn-by-Turn Card
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                width: 290,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceContainer.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: widget.theme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.theme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.turn_right_rounded,
                        size: 26,
                        color: widget.theme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${widget.navigationState.distanceToNextTurnMeters.toStringAsFixed(0)} m',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: widget.theme.onSurface,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: widget.theme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'IN 30s',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: widget.theme.primary,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Turn right onto ${widget.navigationState.destinationName} Rd',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.theme.onSurfaceVariant,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Top-Right: Map Floating Controls (Zoom, 3D, Mute)
            Positioned(
              top: 14,
              right: 14,
              child: Column(
                children: [
                  _buildMapActionButton(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => _zoom = (_zoom + 0.15).clamp(0.7, 1.6)),
                  ),
                  const SizedBox(height: 6),
                  _buildMapActionButton(
                    icon: Icons.remove_rounded,
                    onTap: () => setState(() => _zoom = (_zoom - 0.15).clamp(0.7, 1.6)),
                  ),
                  const SizedBox(height: 6),
                  _buildMapActionButton(
                    icon: _is3d ? Icons.layers_rounded : Icons.map_rounded,
                    onTap: () => setState(() => _is3d = !_is3d),
                  ),
                  const SizedBox(height: 6),
                  _buildMapActionButton(
                    icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                ],
              ),
            ),

            // 4. Bottom Horizontal POI Shortcut Strip
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceContainer.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.theme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: _pois.map((poi) {
                    final isSel = _selectedPoi == poi.name;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPoi = poi.name),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? widget.theme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  poi.icon,
                                  size: 15,
                                  color: isSel
                                      ? widget.theme.onPrimaryContainer
                                      : widget.theme.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        poi.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                          color: isSel
                                              ? widget.theme.onPrimaryContainer
                                              : widget.theme.onSurface,
                                          fontFamily: 'Space Grotesk',
                                        ),
                                      ),
                                      Text(
                                        '${poi.dist} · ${poi.eta}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isSel
                                              ? widget.theme.onPrimaryContainer.withValues(alpha: 0.8)
                                              : widget.theme.outline,
                                          fontFamily: 'Space Grotesk',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.theme.surfaceContainer.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.theme.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: widget.theme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PoiItem {
  final String name;
  final String dist;
  final String eta;
  final IconData icon;

  const _PoiItem({
    required this.name,
    required this.dist,
    required this.eta,
    required this.icon,
  });
}

class _M3MapCanvasPainter extends CustomPainter {
  final HudTheme theme;
  final double zoom;
  final bool is3d;

  _M3MapCanvasPainter({
    required this.theme,
    required this.zoom,
    required this.is3d,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background Land
    final landPaint = Paint()..color = const Color(0xFF12151B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    // 2. Open Green Spaces
    final parkPaint = Paint()
      ..color = const Color(0xFF172E21).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final park1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.1)
      ..lineTo(size.width * 0.25, size.height * 0.15)
      ..lineTo(size.width * 0.22, size.height * 0.35)
      ..lineTo(size.width * 0.08, size.height * 0.3)
      ..close();
    canvas.drawPath(park1, parkPaint);

    final park2 = Path()
      ..moveTo(size.width * 0.65, size.height * 0.2)
      ..lineTo(size.width * 0.88, size.height * 0.18)
      ..lineTo(size.width * 0.85, size.height * 0.45)
      ..lineTo(size.width * 0.64, size.height * 0.4)
      ..close();
    canvas.drawPath(park2, parkPaint);

    // 3. Arterial Secondary Roads
    final roadPaint = Paint()
      ..color = const Color(0xFF252932)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * zoom
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.48),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.68),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.28, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, 0),
      Offset(size.width * 0.74, size.height),
      roadPaint,
    );

    // 4. Main Planned GPS Route Line
    final routePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.95)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.52,
        size.width * 0.56,
        size.height * 0.48,
      )
      ..lineTo(size.width * 0.75, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.35,
        size.width * 0.82,
        size.height * 0.25,
      )
      ..lineTo(size.width * 0.82, size.height * 0.15);

    // Route Outer Glow / Casing
    final routeGlowPaint = Paint()
      ..color = theme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 * zoom
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routeGlowPaint);

    // Route Main Line
    final routeLinePaint = Paint()
      ..color = theme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * zoom
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routeLinePaint);

    // 5. Rider GPS Puck (Current Vehicle Position)
    final riderPos = Offset(size.width * 0.5, size.height * 0.75);

    // Heading beam cone
    final headingConePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primary.withValues(alpha: 0.4),
          theme.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: riderPos, radius: 45));

    final conePath = Path()
      ..moveTo(riderPos.dx, riderPos.dy)
      ..lineTo(riderPos.dx - 22, riderPos.dy - 45)
      ..lineTo(riderPos.dx + 22, riderPos.dy - 45)
      ..close();
    canvas.drawPath(conePath, headingConePaint);

    // GPS Location Dot
    final puckOuter = Paint()..color = Colors.white;
    final puckInner = Paint()..color = theme.primary;
    canvas.drawCircle(riderPos, 10, puckOuter);
    canvas.drawCircle(riderPos, 7, puckInner);
  }

  @override
  bool shouldRepaint(covariant _M3MapCanvasPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.is3d != is3d ||
        oldDelegate.theme != theme;
  }
}
