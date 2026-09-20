import 'package:flutter/material.dart';
import '../models/hud_theme.dart';

class DocumentTile extends StatelessWidget {
  final String title;
  final String status;
  final HudTheme theme;
  final IconData icon;
  final VoidCallback? onTap;

  const DocumentTile({
    super.key,
    required this.title,
    required this.status,
    required this.theme,
    this.icon = Icons.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileContent = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.card2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.textDim),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: theme.text,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const Spacer(),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: theme.textDim,
              fontFamily: 'Space Grotesk',
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: theme.textDim),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: tileContent,
        ),
      );
    }
    return tileContent;
  }
}
