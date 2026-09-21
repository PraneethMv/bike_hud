import 'package:flutter/material.dart';
import '../models/hud_theme.dart';

class DocumentsPanel extends StatefulWidget {
  final HudTheme theme;
  final bool isEmbedded;

  const DocumentsPanel({
    super.key,
    required this.theme,
    this.isEmbedded = false,
  });

  @override
  State<DocumentsPanel> createState() => _DocumentsPanelState();
}

class _DocumentsPanelState extends State<DocumentsPanel> {
  int _selectedDocIndex = 0;

  final List<_DocItem> _docs = const [
    _DocItem(
      id: 'rc',
      title: 'Registration Certificate (RC)',
      subtitle: 'Ministry of Road Transport & Highways',
      docNumber: 'KA 01 TR 2026',
      holder: 'Praneeth M V',
      validity: '15-Mar-2038',
      status: 'VERIFIED',
      details: [
        MapEntry('Vehicle Class', 'Motorcycle with Gear (MCWG)'),
        MapEntry('Maker / Model', 'KTM Duke 390 Gen-3'),
        MapEntry('Fuel / Type', 'Petrol / BS-VI OBD-2'),
        MapEntry('Chassis No.', 'ME4JC507*K800291'),
        MapEntry('Engine No.', 'JC50E*7401928'),
      ],
    ),
    _DocItem(
      id: 'dl',
      title: 'Driving Licence (DL)',
      subtitle: 'Transport Department, Govt of Karnataka',
      docNumber: 'KA-0120190048291',
      holder: 'Praneeth M V',
      validity: '24-Aug-2041',
      status: 'VALID',
      details: [
        MapEntry('Authorised Vehicles', 'MCWG, LMV'),
        MapEntry('Blood Group', 'O+ Positive'),
        MapEntry('Issuing RTO', 'KA-01 Koramangala, Bengaluru'),
      ],
    ),
    _DocItem(
      id: 'insurance',
      title: 'Comprehensive Insurance Policy',
      subtitle: 'Acko General Insurance Ltd',
      docNumber: 'ACKO-MTR-8849201',
      holder: 'Praneeth M V',
      validity: '14-Oct-2026',
      status: 'EXPIRING_SOON',
      details: [
        MapEntry('Cover Type', '1-Yr Own Damage + 5-Yr Third Party'),
        MapEntry('IDV Value', '₹ 2,95,000'),
        MapEntry('24x7 Roadside Support', 'Active Included'),
      ],
    ),
    _DocItem(
      id: 'puc',
      title: 'Pollution Under Control (PUC)',
      subtitle: 'Emission Testing Centre #KA01-094',
      docNumber: 'PUC-KA01-2026-9921',
      holder: 'KA 01 TR 2026',
      validity: '18-Jan-2027',
      status: 'VALID',
      details: [
        MapEntry('CO (%) Reading', '0.12 (Limit: 0.50)'),
        MapEntry('HC (PPM) Reading', '180 (Limit: 750)'),
        MapEntry('Emission Norm', 'BS-VI OBD Compliant'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDoc = _docs[_selectedDocIndex];

    final content = Column(
      children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.theme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.badge_rounded,
                      size: 20,
                      color: widget.theme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Vehicle Wallet & DigiLocker',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.onSurface,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.theme.primaryContainer.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: widget.theme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Offline Encrypted',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: widget.theme.primary,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Legally recognized digital documents for traffic inspection',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: widget.theme.onSurfaceVariant,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Number Plate Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.theme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'IND ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.outline,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    Text(
                      'KA 01 TR 2026',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: widget.theme.onSurface,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main 2-Column Layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: Document Selectable List (Width: 260px)
                SizedBox(
                  width: 260,
                  child: ListView.separated(
                    itemCount: _docs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final doc = _docs[idx];
                      final isSelected = _selectedDocIndex == idx;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDocIndex = idx),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.theme.surfaceContainerHigh
                                  : widget.theme.surfaceContainer,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? widget.theme.primary.withValues(alpha: 0.6)
                                    : widget.theme.outlineVariant.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        doc.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? widget.theme.onSurface
                                              : widget.theme.onSurfaceVariant,
                                          fontFamily: 'Space Grotesk',
                                        ),
                                      ),
                                    ),
                                    _buildDocStatusChip(doc.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doc.docNumber,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? widget.theme.primary : widget.theme.outline,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Valid till: ${doc.validity}',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: widget.theme.outline,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // Right Column: Document Details Preview Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: widget.theme.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Details Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedDoc.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: widget.theme.onSurface,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                                Text(
                                  selectedDoc.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: widget.theme.onSurfaceVariant,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: widget.theme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: widget.theme.outlineVariant.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.qr_code_2_rounded, size: 16, color: widget.theme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Digital QR',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: widget.theme.onSurface,
                                      fontFamily: 'Space Grotesk',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Document metadata key-values
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 3.2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 8,
                            children: [
                              _buildMetaField('HOLDER NAME', selectedDoc.holder),
                              _buildMetaField('DOC NUMBER', selectedDoc.docNumber),
                              _buildMetaField('VALIDITY DATE', selectedDoc.validity),
                              ...selectedDoc.details.map((d) => _buildMetaField(d.key.toUpperCase(), d.value)),
                            ],
                          ),
                        ),

                        // Verification notice
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: widget.theme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: widget.theme.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified_user_rounded, size: 16, color: widget.theme.statusGpsOk),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Digitally signed & verified with DigiLocker API • Complies with IT Act 2000',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: widget.theme.onSurfaceVariant,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

    if (widget.isEmbedded) {
      return content;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.theme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: content,
    );
  }

  Widget _buildMetaField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.theme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.theme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: widget.theme.outline,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.theme.onSurface,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocStatusChip(String status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case 'VERIFIED':
        bg = widget.theme.primaryContainer.withValues(alpha: 0.4);
        fg = widget.theme.primary;
        label = 'VERIFIED';
        icon = Icons.check_circle_rounded;
        break;
      case 'EXPIRING_SOON':
        bg = widget.theme.errorContainer.withValues(alpha: 0.4);
        fg = widget.theme.error;
        label = 'RENEW SOON';
        icon = Icons.warning_amber_rounded;
        break;
      default:
        bg = widget.theme.surfaceContainerHigh;
        fg = widget.theme.onSurfaceVariant;
        label = 'VALID';
        icon = Icons.shield_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: fg,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}

class _DocItem {
  final String id;
  final String title;
  final String subtitle;
  final String docNumber;
  final String holder;
  final String validity;
  final String status;
  final List<MapEntry<String, String>> details;

  const _DocItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.docNumber,
    required this.holder,
    required this.validity,
    required this.status,
    required this.details,
  });
}
