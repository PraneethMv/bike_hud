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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.line.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DockItem(
            icon: Icons.speed_rounded,
            label: 'Dash',
            isSelected: currentScreen == HudScreen.dashboard,
            onTap: () => onScreenSelected(HudScreen.dashboard),
            theme: theme,
          ),
          const SizedBox(width: 6),
          _DockItem(
            icon: Icons.navigation_rounded,
            label: 'Nav',
            isSelected: currentScreen == HudScreen.navigation,
            onTap: () => onScreenSelected(HudScreen.navigation),
            theme: theme,
          ),
          const SizedBox(width: 6),
          _DockItem(
            icon: Icons.description_rounded,
            label: 'Docs',
            isSelected: currentScreen == HudScreen.documents,
            onTap: () => onScreenSelected(HudScreen.documents),
            theme: theme,
          ),
          const SizedBox(width: 6),
          _DockItem(
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

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final HudTheme theme;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? theme.accentDim : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? theme.accent.withValues(alpha: 0.35)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? theme.accent : theme.textDim,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.accent,
                      fontFamily: 'Space Grotesk',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
