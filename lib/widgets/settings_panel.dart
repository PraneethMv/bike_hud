import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import '../services/bluetooth_service.dart';
import '../screens/splash_screen.dart';
import 'documents_panel.dart';

enum SettingsSection {
  display,
  vehicleInfo,
  documents,
  connectivity,
  system,
}

class SettingsPanel extends StatefulWidget {
  final HudTheme theme;
  final bool phoneConnected;
  final ValueChanged<bool> onPhoneConnectionChanged;
  final bool initialShowConnectivity;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ThemeMode themeMode;
  final String accentColor;
  final ValueChanged<String>? onAccentColorChanged;
  final List<Map<String, dynamic>>? recentRides;
  final String userName;
  final double fuelTankCapacityLiters;
  final double currentOdoKm;
  final ValueChanged<double>? onOdoUpdated;
  final String vehicleModel;
  final String fuelType;

  const SettingsPanel({
    super.key,
    required this.theme,
    required this.phoneConnected,
    required this.onPhoneConnectionChanged,
    this.initialShowConnectivity = false,
    this.onThemeModeChanged,
    this.themeMode = ThemeMode.dark,
    this.accentColor = 'blue',
    this.onAccentColorChanged,
    this.recentRides,
    this.userName = 'Praneeth',
    this.fuelTankCapacityLiters = 13.5,
    this.currentOdoKm = 14820.0,
    this.onOdoUpdated,
    this.vehicleModel = 'Triumph Speed 400',
    this.fuelType = 'Petrol',
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final BluetoothService _bluetoothService = BluetoothService();
  SettingsSection _activeSection = SettingsSection.display;

  // Display options
  double _brightness = 85.0;
  String _colorSeed = 'blue';
  String _speedUnit = 'km/h';
  String _tempUnit = '°C';

  // Vehicle Information & Alerts options
  bool _overspeedWarningEnabled = true;
  int _speedAlertThreshold = 80;
  bool _audioChimes = true;
  double? _previousOdoKm;

  // Bluetooth scanning & state
  bool _bluetoothEnabled = true;
  bool _isScanning = false;
  List<BluetoothDeviceInfo> _nearbyDevices = [];
  String? _connectingDeviceName;
  String? _pairedDeviceName;
  Timer? _scanTimer;
  Timer? _connectTimer;
  Timer? _undoTimeoutTimer;

  // OTA state
  bool _isCheckingOta = false;
  bool _otaSuccess = false;

  @override
  void initState() {
    super.initState();
    _colorSeed = widget.accentColor;
    _activeSection = widget.initialShowConnectivity
        ? SettingsSection.connectivity
        : SettingsSection.display;

    if (widget.phoneConnected) {
      _pairedDeviceName = "Paired Phone";
    }

    if (_activeSection == SettingsSection.connectivity &&
        _bluetoothEnabled &&
        _nearbyDevices.isEmpty &&
        !_isScanning) {
      _startScan();
    }
  }

  @override
  void didUpdateWidget(SettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accentColor != oldWidget.accentColor) {
      setState(() {
        _colorSeed = widget.accentColor;
      });
    }
    if (widget.initialShowConnectivity != oldWidget.initialShowConnectivity &&
        widget.initialShowConnectivity) {
      setState(() {
        _activeSection = SettingsSection.connectivity;
      });
      if (_bluetoothEnabled && _nearbyDevices.isEmpty && !_isScanning) {
        _startScan();
      }
    }
    if (widget.phoneConnected && _pairedDeviceName == null) {
      setState(() {
        _pairedDeviceName = "Paired Phone";
      });
    } else if (!widget.phoneConnected && _pairedDeviceName != null) {
      setState(() {
        _pairedDeviceName = null;
      });
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _connectTimer?.cancel();
    _undoTimeoutTimer?.cancel();
    super.dispose();
  }

  void _startScan() {
    if (!_bluetoothEnabled || _isScanning) return;

    setState(() {
      _isScanning = true;
      _nearbyDevices = [];
    });

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _nearbyDevices = _bluetoothService.getMockAvailableDevices();
        });
      }
    });
  }

  void _toggleBluetooth(bool value) {
    setState(() {
      _bluetoothEnabled = value;
      if (!value) {
        _isScanning = false;
        _nearbyDevices = [];
        _connectingDeviceName = null;
      }
    });

    if (value) {
      _startScan();
    }
  }

  void _handleDeviceTap(BluetoothDeviceInfo device) {
    if (_connectingDeviceName != null || widget.phoneConnected) return;

    setState(() {
      _connectingDeviceName = device.name;
    });

    _connectTimer?.cancel();
    _connectTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _showPairingDialog(device);
      }
    });
  }

  void _showPairingDialog(BluetoothDeviceInfo device) {
    final int pinCode = 100000 + (DateTime.now().millisecond * 999) % 899999;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = widget.theme;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: theme.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bluetooth_searching_rounded, color: theme.primary, size: 40),
                const SizedBox(height: 14),
                Text(
                  'PAIRING REQUEST',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.onSurface,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirm passkey matches on ${device.name}:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.onSurfaceVariant,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    pinCode.toString().replaceAllMapped(
                          RegExp(r".{3}"),
                          (match) => "${match.group(0)} ",
                        ),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _connectingDeviceName = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: theme.onSurfaceVariant,
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _connectingDeviceName = null;
                            _pairedDeviceName = device.name;
                          });
                          widget.onPhoneConnectionChanged(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: theme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CONFIRM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _disconnect() {
    setState(() {
      _pairedDeviceName = null;
      _connectingDeviceName = null;
    });
    widget.onPhoneConnectionChanged(false);
  }

  void _checkOta() {
    setState(() {
      _isCheckingOta = true;
      _otaSuccess = false;
    });
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isCheckingOta = false;
          _otaSuccess = true;
        });
      }
    });
  }

  void _undoOdoOverride([double? fallbackOdo]) {
    _undoTimeoutTimer?.cancel();
    final targetOdo = _previousOdoKm ?? fallbackOdo;
    if (targetOdo != null) {
      widget.onOdoUpdated?.call(targetOdo);
    }
    if (mounted) {
      setState(() {
        _previousOdoKm = null;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'HUD Odometer reverted to ${targetOdo?.toStringAsFixed(1) ?? ""} km',
            style: const TextStyle(fontFamily: 'Space Grotesk'),
          ),
          backgroundColor: widget.theme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showOdoSyncDialog() {
    final theme = widget.theme;
    double candidateOdo = widget.currentOdoKm >= 15240.0 ? widget.currentOdoKm + 350.0 : 15240.0;
    final TextEditingController textController = TextEditingController(text: candidateOdo.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final enteredVal = double.tryParse(textController.text) ?? candidateOdo;
            final isLower = enteredVal < widget.currentOdoKm;
            final diff = enteredVal - widget.currentOdoKm;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.phonelink_setup_rounded, color: theme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SYNC CLUSTER ODOMETER',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: theme.onSurface,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Synchronize the high-accuracy odometer value recorded from your vehicle\'s integrated instrument cluster via Rev Companion App.',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.onSurfaceVariant,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Comparison card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current HUD ODO',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: theme.onSurfaceVariant,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${widget.currentOdoKm.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.onSurface,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: theme.outline),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Companion Reading',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: theme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${enteredVal.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primary,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                                Text(
                                  diff >= 0
                                      ? '+${diff.toStringAsFixed(1)} km'
                                      : '${diff.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: diff >= 0 ? Colors.tealAccent : Colors.orangeAccent,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Warning if lower
                    if (isLower) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Warning: Phone reading is lower than current HUD ODO. Vehicle cluster reading should normally only increase.',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.amber.shade200,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Quick presets
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Simulate Cluster Input:',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: theme.onSurfaceVariant,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                        for (final offset in [100.0, 420.0, -100.0])
                          GestureDetector(
                            onTap: () {
                              final newVal = (widget.currentOdoKm + offset).clamp(0.0, 999999.0);
                              textController.text = newVal.toStringAsFixed(1);
                              setDialogState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                offset > 0 ? '+${offset.toInt()} km' : '${offset.toInt()} km',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                color: theme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final finalVal = double.tryParse(textController.text) ?? candidateOdo;
                              final prevOdo = widget.currentOdoKm;
                              Navigator.of(dialogContext).pop();

                              _undoTimeoutTimer?.cancel();
                              if (mounted) {
                                setState(() {
                                  _previousOdoKm = prevOdo;
                                });
                              }
                              _undoTimeoutTimer = Timer(const Duration(seconds: 5), () {
                                if (mounted) {
                                  setState(() {
                                    _previousOdoKm = null;
                                  });
                                }
                              });

                              widget.onOdoUpdated?.call(finalVal);
                              if (mounted) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'HUD Odometer synced to ${finalVal.toStringAsFixed(1)} km from phone app.',
                                      style: const TextStyle(fontFamily: 'Space Grotesk'),
                                    ),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      textColor: theme.primary,
                                      onPressed: () => _undoOdoOverride(prevOdo),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 5),
                                    backgroundColor: theme.surfaceContainerHighest,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary,
                              foregroundColor: theme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'SYNC & OVERRIDE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          // Top Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      size: 20,
                      color: theme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AeroHUD System Settings',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Text(
                        'Display customization, alerts, Bluetooth pairing & system diagnostics',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: theme.onSurfaceVariant,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Current OS Version Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rev HUD OS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  Text(
                    'RevHUD - v0.1.0 • Build 8402',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: theme.outline,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Android Tablet Style Split Screen Layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Left Navigation Menu (Width: 240px)
                SizedBox(
                  width: 240,
                  child: Column(
                    children: [
                      _buildMenuCategory(
                        section: SettingsSection.display,
                        icon: Icons.palette_rounded,
                        label: 'Display',
                        theme: theme,
                      ),
                      const SizedBox(height: 6),
                      _buildMenuCategory(
                        section: SettingsSection.vehicleInfo,
                        icon: Icons.two_wheeler_rounded,
                        label: 'Vehicle Information',
                        theme: theme,
                      ),
                      const SizedBox(height: 6),
                      _buildMenuCategory(
                        section: SettingsSection.documents,
                        icon: Icons.badge_outlined,
                        label: 'Vehicle Documents',
                        theme: theme,
                      ),
                      const SizedBox(height: 6),
                      _buildMenuCategory(
                        section: SettingsSection.connectivity,
                        icon: Icons.bluetooth_rounded,
                        label: 'Bluetooth',
                        theme: theme,
                      ),
                      const SizedBox(height: 6),
                      _buildMenuCategory(
                        section: SettingsSection.system,
                        icon: Icons.tune_rounded,
                        label: 'System',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Right Detail Content Panel
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: _activeSection == SettingsSection.documents
                        ? DocumentsPanel(theme: theme, isEmbedded: true)
                        : SingleChildScrollView(
                            child: _buildSelectedSectionContent(theme),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory({
    required SettingsSection section,
    required IconData icon,
    required String label,
    required HudTheme theme,
  }) {
    final isSelected = _activeSection == section;

    return GestureDetector(
      onTap: () {
        setState(() => _activeSection = section);
        if (section == SettingsSection.connectivity &&
            _bluetoothEnabled &&
            _nearbyDevices.isEmpty &&
            !_isScanning) {
          _startScan();
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? theme.surfaceContainerHigh : theme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.primary.withValues(alpha: 0.5)
                  : theme.outlineVariant.withValues(alpha: 0.2),
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryContainer : theme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isSelected ? theme.onPrimaryContainer : theme.outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? theme.onSurface : theme.onSurfaceVariant,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, {bool isAccent = false, required HudTheme theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            color: theme.onSurfaceVariant,
            fontFamily: 'Space Grotesk',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: isAccent ? theme.primary : theme.onSurface,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSectionContent(HudTheme theme) {
    switch (_activeSection) {
      case SettingsSection.display:
        return _buildDisplaySection(theme);
      case SettingsSection.vehicleInfo:
        return _buildVehicleInfoSection(theme);
      case SettingsSection.documents:
        return DocumentsPanel(theme: theme, isEmbedded: true);
      case SettingsSection.connectivity:
        return _buildConnectivitySection(theme);
      case SettingsSection.system:
        return _buildSystemSection(theme);
    }
  }

  // Section 1: Display
  Widget _buildDisplaySection(HudTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_rounded, size: 16, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              'Display & Appearance',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Theme Mode Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Mode',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildThemeOption(
                    mode: ThemeMode.dark,
                    label: 'Dark (Night)',
                    icon: Icons.nightlight_round_rounded,
                    isSelected: widget.themeMode == ThemeMode.dark,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    mode: ThemeMode.light,
                    label: 'Light (Day)',
                    icon: Icons.wb_sunny_rounded,
                    isSelected: widget.themeMode == ThemeMode.light,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    mode: ThemeMode.system,
                    label: 'Auto (Ambient Sensor)',
                    icon: Icons.brightness_auto_rounded,
                    isSelected: widget.themeMode == ThemeMode.system,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Dynamic Material You Accent Swatches
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accent Color',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildColorSeedOption('blue', 'Android Blue', const Color(0xFF3B82F6), theme),
                  const SizedBox(width: 8),
                  _buildColorSeedOption('emerald', 'Forest Green', const Color(0xFF10B981), theme),
                  const SizedBox(width: 8),
                  _buildColorSeedOption('amber', 'Desert Amber', const Color(0xFFF59E0B), theme),
                  const SizedBox(width: 8),
                  _buildColorSeedOption('purple', 'Lavender', const Color(0xFFA855F7), theme),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Display Brightness Slider
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Display Brightness',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  Text(
                    '${_brightness.round()}% (High Nits Anti-Glare)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
              Slider(
                value: _brightness,
                min: 20,
                max: 100,
                activeColor: theme.primary,
                inactiveColor: theme.surfaceContainerLow,
                onChanged: (val) => setState(() => _brightness = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Units: Speed & Temperature
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speed Unit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['km/h', 'mph'].map((u) {
                        final isSel = _speedUnit == u;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _speedUnit = u),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? theme.primaryContainer : theme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  u,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? theme.onPrimaryContainer : theme.outline,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature Unit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['°C', '°F'].map((u) {
                        final isSel = _tempUnit == u;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tempUnit = u),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? theme.primaryContainer : theme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  u,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? theme.onPrimaryContainer : theme.outline,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
    required HudTheme theme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.onThemeModeChanged != null) {
            widget.onThemeModeChanged!(mode);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? theme.primaryContainer : theme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? theme.primary : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: isSelected ? theme.onPrimaryContainer : theme.outline),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.onPrimaryContainer : theme.onSurfaceVariant,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSeedOption(String id, String label, Color color, HudTheme theme) {
    final isSelected = _colorSeed == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _colorSeed = id);
          widget.onAccentColorChanged?.call(id);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? theme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.onSurface : theme.outline,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section 2: Vehicle Information & Safety Alerts
  Widget _buildVehicleInfoSection(HudTheme theme) {
    final gallons = widget.fuelTankCapacityLiters * 0.264172;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.two_wheeler_rounded, size: 16, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              'Vehicle Information & Safety Alerts',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 1. Vehicle Model & Fuel Type Card (Read-only from phone)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.two_wheeler_rounded, size: 20, color: theme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Vehicle Model',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'READ-ONLY',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: theme.outline,
                                    fontFamily: 'Space Grotesk',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Synced from Rev Companion Mobile App',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.onSurfaceVariant,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    widget.vehicleModel,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_gas_station_outlined, size: 14, color: theme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Fuel Type',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.onSurfaceVariant,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.fuelType,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Full Tank Capacity Card (Read-only from phone)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_gas_station_rounded, size: 20, color: theme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Full Tank Capacity',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: theme.onSurface,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'READ-ONLY',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: theme.outline,
                              fontFamily: 'Space Grotesk',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configured via Rev Companion Mobile App',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.onSurfaceVariant,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.fuelTankCapacityLiters.toStringAsFixed(1)} L',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  Text(
                    '${gallons.toStringAsFixed(2)} Gal',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.onSurfaceVariant,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Vehicle ODO Override Card (with Failsafe Undo)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.av_timer_rounded, size: 20, color: theme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle ODO Override',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: theme.onSurface,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                          Text(
                            'Sync cluster reading from phone app (cluster is more accurate than GPS)',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: theme.onSurfaceVariant,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.currentOdoKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Text(
                        'HUD Total ODO',
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.onSurfaceVariant,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Buttons row: Sync & Undo
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showOdoSyncDialog,
                    icon: const Icon(Icons.sync_rounded, size: 14),
                    label: const Text(
                      'Sync ODO from Phone',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                  if (_previousOdoKm != null)
                    OutlinedButton.icon(
                      onPressed: _undoOdoOverride,
                      icon: const Icon(Icons.undo_rounded, size: 14),
                      label: Text(
                        'Undo Override (${_previousOdoKm!.toStringAsFixed(1)} km)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orangeAccent,
                        side: const BorderSide(color: Colors.orangeAccent, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Overspeed Warning Alert Card (with Master Toggle)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overspeed Warning Alert',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Text(
                        _overspeedWarningEnabled
                            ? 'Pulsing visual alert on speedometer when riding above threshold'
                            : 'Alert disabled — speedometer will not pulse when over speed limit',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.onSurfaceVariant,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_overspeedWarningEnabled)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$_speedAlertThreshold $_speedUnit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.onPrimaryContainer,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ),
                      Switch(
                        value: _overspeedWarningEnabled,
                        activeThumbColor: theme.primary,
                        onChanged: (val) => setState(() => _overspeedWarningEnabled = val),
                      ),
                    ],
                  ),
                ],
              ),
              if (_overspeedWarningEnabled) ...[
                const SizedBox(height: 10),
                Row(
                  children: [50, 60, 80, 100].map((limit) {
                    final isSel = _speedAlertThreshold == limit;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _speedAlertThreshold = limit),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? theme.primaryContainer : theme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSel ? theme.primary : theme.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$limit $_speedUnit',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isSel ? theme.onPrimaryContainer : theme.outline,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Audio Voice & Turn Prompts Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio Voice & Turn Prompts',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: theme.onSurface, fontFamily: 'Space Grotesk'),
                  ),
                  Text(
                    'Route audio navigation guidance to helmet headset',
                    style: TextStyle(fontSize: 10, color: theme.onSurfaceVariant, fontFamily: 'Space Grotesk'),
                  ),
                ],
              ),
              Switch(
                value: _audioChimes,
                activeThumbColor: theme.primary,
                onChanged: (val) => setState(() => _audioChimes = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section 4: Bluetooth
  Widget _buildConnectivitySection(HudTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.bluetooth_rounded, size: 16, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  'Bluetooth Pairing',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
            Switch(
              value: _bluetoothEnabled,
              activeThumbColor: theme.primary,
              onChanged: _toggleBluetooth,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Helmet Intercom Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.headphones_rounded, size: 18, color: theme.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sena 50S Intercom',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.onSurface, fontFamily: 'Space Grotesk'),
                    ),
                    Text(
                      'Connected (A2DP Music + HFP Intercom)',
                      style: TextStyle(fontSize: 10, color: theme.statusGpsOk, fontFamily: 'Space Grotesk'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Phone Status / Paired Device Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.phoneConnected ? theme.primaryContainer : theme.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_android_rounded,
                  size: 18,
                  color: widget.phoneConnected ? theme.onPrimaryContainer : theme.outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.phoneConnected ? (_pairedDeviceName ?? 'Connected Phone') : 'No Phone Paired',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.onSurface, fontFamily: 'Space Grotesk'),
                    ),
                    Text(
                      widget.phoneConnected ? 'Wireless Android Auto • 5GHz Link' : 'Pair phone to enable navigation & calls',
                      style: TextStyle(fontSize: 10, color: theme.onSurfaceVariant, fontFamily: 'Space Grotesk'),
                    ),
                  ],
                ),
              ),
              if (widget.phoneConnected)
                ElevatedButton(
                  onPressed: _disconnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.errorContainer,
                    foregroundColor: theme.error,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                  ),
                  child: const Text('Disconnect', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Available Nearby Devices List
        if (!widget.phoneConnected && _bluetoothEnabled) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE DEVICES',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: theme.outline, fontFamily: 'Space Grotesk'),
              ),
              if (_isScanning)
                Row(
                  children: [
                    SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary)),
                    const SizedBox(width: 6),
                    Text('Scanning...', style: TextStyle(fontSize: 10, color: theme.primary, fontFamily: 'Space Grotesk')),
                  ],
                )
              else
                GestureDetector(
                  onTap: _startScan,
                  child: Text('Scan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primary, fontFamily: 'Space Grotesk')),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ..._nearbyDevices.map((dev) {
            final isConn = _connectingDeviceName == dev.name;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.devices_rounded, size: 16, color: theme.outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dev.name, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: theme.onSurface, fontFamily: 'Space Grotesk')),
                        Text(dev.address, style: TextStyle(fontSize: 9.5, color: theme.outline, fontFamily: 'Space Grotesk')),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isConn ? null : () => _handleDeviceTap(dev),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 0,
                    ),
                    child: Text(isConn ? 'Pairing...' : 'Pair', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // Section 4: System
  Widget _buildSystemSection(HudTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_rounded, size: 16, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              'System & Diagnostics',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 1. Hardware Profile Card (Moved from sidebar)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.memory_rounded, size: 15, color: theme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Hardware Profile',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildProfileRow('Vehicle Interface', 'Universal (Agnostic)', isAccent: true, theme: theme),
              const SizedBox(height: 6),
              _buildProfileRow('Power Input', '12V DC (9-18V Regulated)', theme: theme),
              const SizedBox(height: 6),
              _buildProfileRow('Internal Battery', '100% (Li-ion 2500mAh)', theme: theme),
              const SizedBox(height: 6),
              _buildProfileRow('Processor', 'Quad-Core ARM @ 1.8 GHz', theme: theme),
              const SizedBox(height: 6),
              _buildProfileRow('Board Revision', 'Rev 3.2 Automotive', theme: theme),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. GNSS & Location Telemetry Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.satellite_alt_rounded, size: 15, color: theme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'GNSS / GPS Receiver',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildGnssMetricBox('FIX STATUS', '3D FIX (GNSS)', isAccent: true, theme: theme),
                  _buildGnssMetricBox('SATELLITES', '12 Locked', theme: theme),
                  _buildGnssMetricBox('ELEVATION', '920 m ASL', theme: theme),
                  _buildGnssMetricBox('ACCURACY', '±1.2 meters', theme: theme),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. OTA Firmware Update Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.system_update_rounded, size: 18, color: theme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firmware Update',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.onSurface, fontFamily: 'Space Grotesk'),
                      ),
                      Text(
                        _otaSuccess ? 'Your Rev HUD unit is up to date' : 'Check for latest automotive OTA updates',
                        style: TextStyle(fontSize: 10, color: theme.onSurfaceVariant, fontFamily: 'Space Grotesk'),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _isCheckingOta ? null : _checkOta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: 0,
                ),
                child: Text(
                  _isCheckingOta ? 'Checking...' : (_otaSuccess ? 'Up to date' : 'Check Updates'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Startup & Boot Display Preview Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.speed_rounded, size: 18, color: theme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Startup Display',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.onSurface, fontFamily: 'Space Grotesk'),
                      ),
                      Text(
                        'Aesthetic Rev HUD boot screen & SBC diagnostics',
                        style: TextStyle(fontSize: 10, color: theme.onSurfaceVariant, fontFamily: 'Space Grotesk'),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SplashScreen(
                        userName: widget.userName,
                        onFinished: () => Navigator.of(context).pop(),
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Preview Splash', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGnssMetricBox(String label, String value, {bool isAccent = false, required HudTheme theme}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: theme.outline, fontFamily: 'Space Grotesk')),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAccent ? theme.primary : theme.onSurface,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}
