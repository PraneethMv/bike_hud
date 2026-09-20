import 'package:flutter/material.dart';
import '../models/hud_screen.dart';
import '../models/hud_theme.dart';

class NavDock extends StatelessWidget {
  final HudScreen currentScreen;
  final ValueChanged<HudScreen> onScreenSelected;
  final HudTheme theme;

  const NavDock({
    super.key,
    required this.currentScreen,
    required this.onScreenSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.outlineVariant.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _M3NavItem(
            icon: Icons.speed_rounded,
            label: 'Dashboard',
            isSelected: currentScreen == HudScreen.dashboard,
            onTap: () => onScreenSelected(HudScreen.dashboard),
            theme: theme,
          ),
          const SizedBox(width: 8),
          _M3NavItem(
            icon: Icons.navigation_rounded,
            label: 'Navigation',
            isSelected: currentScreen == HudScreen.navigation,
            onTap: () => onScreenSelected(HudScreen.navigation),
            theme: theme,
          ),
          const SizedBox(width: 8),
          _M3NavItem(
            icon: Icons.badge_outlined,
            label: 'Documents',
            isSelected: currentScreen == HudScreen.documents,
            onTap: () => onScreenSelected(HudScreen.documents),
            theme: theme,
          ),
          const SizedBox(width: 8),
          _M3NavItem(
            icon: Icons.tune_rounded,
            label: 'Settings',
            isSelected: currentScreen == HudScreen.settings,
            onTap: () => onScreenSelected(HudScreen.settings),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _M3NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final HudTheme theme;

  const _M3NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // M3 Active Pill Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 54,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? theme.onPrimaryContainer
                        : theme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // M3 Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? theme.onSurface : theme.outline,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
