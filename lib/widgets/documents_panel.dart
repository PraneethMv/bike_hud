import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import 'hud_card.dart';
import 'document_tile.dart';

class DocumentsPanel extends StatelessWidget {
  final HudTheme theme;

  const DocumentsPanel({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return HudCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOCUMENTS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.text,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 12),
          DocumentTile(title: 'Registration Certificate', status: 'Stored', theme: theme),
          DocumentTile(title: 'Driving Licence', status: 'Stored', theme: theme),
          DocumentTile(title: 'Insurance', status: 'Not added', theme: theme),
          DocumentTile(title: 'PUC Certificate', status: 'Not added', theme: theme),
          const Spacer(),
          Text(
            'Later: encrypt these files and lock behind PIN/biometric access.',
            style: TextStyle(color: theme.textFaint, fontFamily: 'Space Grotesk'),
          ),
        ],
      ),
    );
  }
}
