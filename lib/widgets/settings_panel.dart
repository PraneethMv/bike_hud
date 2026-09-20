import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import '../services/bluetooth_service.dart';

enum SettingsSection {
  display,
  alerts,
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

  // Alerts & ride stats options
  int _speedAlertThreshold = 80;
  bool _audioChimes = true;
  bool _isSendingRideData = false;

  // Bluetooth scanning & state
  bool _bluetoothEnabled = true;
  bool _isScanning = false;
  List<BluetoothDeviceInfo> _nearbyDevices = [];
  String? _connectingDeviceName;
  String? _pairedDeviceName;
  Timer? _scanTimer;
  Timer? _connectTimer;

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
                    'AeroHUD Automotive',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  Text(
                    'Version 2.4.0 • Build 8402',
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
                        section: SettingsSection.alerts,
                        icon: Icons.analytics_rounded,
                        label: 'Ride Statistics & Alerts',
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
                    child: SingleChildScrollView(
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
      case SettingsSection.alerts:
        return _buildAlertsSection(theme);
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

  // Recent 5 Rides Data
  final List<Map<String, dynamic>> _recentRides = const [
    {
      'title': 'Ride #5',
      'date': 'Today, 08:30 AM',
      'duration': '42 min',
      'distanceKm': 24.6,
      'avgSpeedKm': 35,
      'topSpeedKm': 78,
    },
    {
      'title': 'Ride #4',
      'date': 'Yesterday, 06:15 PM',
      'duration': '1h 15m',
      'distanceKm': 52.3,
      'avgSpeedKm': 42,
      'topSpeedKm': 92,
    },
    {
      'title': 'Ride #3',
      'date': '19 Sep, 07:45 AM',
      'duration': '28 min',
      'distanceKm': 16.8,
      'avgSpeedKm': 36,
      'topSpeedKm': 68,
    },
    {
      'title': 'Ride #2',
      'date': '18 Sep, 05:20 PM',
      'duration': '54 min',
      'distanceKm': 38.2,
      'avgSpeedKm': 42,
      'topSpeedKm': 86,
    },
    {
      'title': 'Ride #1',
      'date': '17 Sep, 09:10 AM',
      'duration': '1h 02m',
      'distanceKm': 45.0,
      'avgSpeedKm': 43,
      'topSpeedKm': 94,
    },
  ];

  void _sendDataToPhone() {
    if (_isSendingRideData) return;
    setState(() => _isSendingRideData = true);

    Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _isSendingRideData = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.phoneConnected
                  ? 'Ride statistics successfully synced with paired phone'
                  : 'Ride data saved locally — will auto-sync when phone connects via Bluetooth',
              style: const TextStyle(fontFamily: 'Space Grotesk'),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            backgroundColor: widget.theme.primaryContainer,
          ),
        );
      }
    });
  }

  // Section 2: Ride Statistics & Alerts
  Widget _buildAlertsSection(HudTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_rounded, size: 16, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              'Ride Statistics & Alerts',
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

        // 1. Ride Statistics Card (Last 5 Sessions)
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
              // Heading Row with "Send Data to Phone" action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights_rounded, size: 15, color: theme.primary),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ride Statistics',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: theme.onSurface,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                          Text(
                            'Last 5 sessions (ignition on → shutdown)',
                            style: TextStyle(fontSize: 9.5, color: theme.onSurfaceVariant, fontFamily: 'Space Grotesk'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSendingRideData ? null : _sendDataToPhone,
                    icon: _isSendingRideData
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: theme.onPrimary),
                          )
                        : Icon(Icons.send_to_mobile_rounded, size: 13, color: theme.onPrimary),
                    label: Text(
                      _isSendingRideData ? 'Syncing...' : 'Send Data to Phone',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent 5 Rides List
              ...(widget.recentRides ?? _recentRides).take(5).map((ride) {
                final dist = _speedUnit == 'mph'
                    ? '${((ride['distanceKm'] as double) * 0.621371).toStringAsFixed(1)} mi'
                    : '${(ride['distanceKm'] as double).toStringAsFixed(1)} km';
                final avg = _speedUnit == 'mph'
                    ? '${((ride['avgSpeedKm'] as int) * 0.621371).round()} mph'
                    : '${ride['avgSpeedKm']} km/h';
                final top = _speedUnit == 'mph'
                    ? '${((ride['topSpeedKm'] as int) * 0.621371).round()} mph'
                    : '${ride['topSpeedKm']} km/h';

                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 115,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride['title'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.onSurface,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                            Text(
                              ride['date'] as String,
                              style: TextStyle(
                                fontSize: 8.5,
                                color: theme.outline,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRideStatCol('RIDE TIME', ride['duration'] as String, Icons.timer_outlined, theme),
                            _buildRideStatCol('DISTANCE', dist, Icons.straighten_rounded, theme),
                            _buildRideStatCol('AVG SPEED', avg, Icons.speed_rounded, theme),
                            _buildRideStatCol('TOP SPEED', top, Icons.bolt_rounded, theme, isAccent: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Overspeed Warning Alert Card
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
                        'Pulsing visual alert on speedometer when riding above threshold',
                        style: TextStyle(fontSize: 10, color: theme.onSurfaceVariant, fontFamily: 'Space Grotesk'),
                      ),
                    ],
                  ),
                  Text(
                    '$_speedAlertThreshold $_speedUnit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
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
          ),
        ),
        const SizedBox(height: 12),

        // 3. Audio Voice & Turn Prompts Toggle
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

  Widget _buildRideStatCol(String label, String value, IconData icon, HudTheme theme, {bool isAccent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 9.5, color: theme.outline),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: theme.outline,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isAccent ? theme.primary : theme.onSurface,
            fontFamily: 'Space Grotesk',
          ),
        ),
      ],
    );
  }

  // Section 3: Bluetooth & Connectivity
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
                        _otaSuccess ? 'Your AeroHUD unit is up to date' : 'Check for latest automotive OTA updates',
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
