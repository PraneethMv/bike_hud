import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import '../services/bluetooth_service.dart';
import 'hud_card.dart';
import 'document_tile.dart';

class SettingsPanel extends StatefulWidget {
  final HudTheme theme;
  final bool phoneConnected;
  final ValueChanged<bool> onPhoneConnectionChanged;
  final bool initialShowConnectivity;

  const SettingsPanel({
    super.key,
    required this.theme,
    required this.phoneConnected,
    required this.onPhoneConnectionChanged,
    this.initialShowConnectivity = false,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final BluetoothService _bluetoothService = BluetoothService();
  late bool _showConnectivity;
  bool _bluetoothEnabled = true;
  bool _isScanning = false;
  List<BluetoothDeviceInfo> _nearbyDevices = [];
  String? _connectingDeviceName;
  String? _pairedDeviceName;
  Timer? _scanTimer;
  Timer? _connectTimer;

  @override
  void initState() {
    super.initState();
    _showConnectivity = widget.initialShowConnectivity;
    if (widget.phoneConnected) {
      _pairedDeviceName = "Paired Device";
    }
    if (_showConnectivity && _bluetoothEnabled && _nearbyDevices.isEmpty && !_isScanning) {
      _startScan();
    }
  }

  @override
  void didUpdateWidget(SettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialShowConnectivity != oldWidget.initialShowConnectivity &&
        widget.initialShowConnectivity) {
      setState(() {
        _showConnectivity = true;
      });
      if (_bluetoothEnabled && _nearbyDevices.isEmpty && !_isScanning) {
        _startScan();
      }
    }
    if (widget.phoneConnected && _pairedDeviceName == null) {
      setState(() {
        _pairedDeviceName = "Paired Device";
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
    // Generate a random 6-digit pin code
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.accent.withValues(alpha: 0.5), width: 1.5),
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
                Icon(Icons.bluetooth_searching_rounded, color: theme.accent, size: 40),
                const SizedBox(height: 14),
                Text(
                  'PAIRING REQUEST',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.text,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirm passkey matches on ${device.name}:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textDim,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.card2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.line),
                  ),
                  child: Text(
                    pinCode.toString().replaceAllMapped(
                          RegExp(r".{3}"),
                          (match) => "${match.group(0)} ",
                        ),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: theme.accent,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                          foregroundColor: theme.textDim,
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
                          backgroundColor: theme.accent,
                          foregroundColor: theme.accentInk,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    if (_showConnectivity) {
      return _buildConnectivityView(theme);
    }

    return HudCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.text,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 12),
          DocumentTile(
            title: 'Connectivity',
            status: widget.phoneConnected
                ? (_pairedDeviceName ?? 'Connected')
                : 'Disconnected',
            theme: theme,
            icon: Icons.bluetooth_connected_rounded,
            onTap: () {
              setState(() {
                _showConnectivity = true;
              });
              if (_bluetoothEnabled && _nearbyDevices.isEmpty && !_isScanning) {
                _startScan();
              }
            },
          ),
          DocumentTile(title: 'Theme', status: theme == HudTheme.dark ? 'Dark' : 'Light', theme: theme, icon: Icons.palette_rounded),
          DocumentTile(title: 'Units', status: 'km/h', theme: theme, icon: Icons.speed_rounded),
          DocumentTile(title: 'Button Mode', status: 'Media + Calls', theme: theme, icon: Icons.radio_button_checked_rounded),
          DocumentTile(title: 'Navigation Provider', status: 'Mock GPS', theme: theme, icon: Icons.map_rounded),
        ],
      ),
    );
  }

  Widget _buildConnectivityView(HudTheme theme) {
    return HudCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: theme.text,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _showConnectivity = false;
                  });
                },
              ),
              const SizedBox(width: 12),
              Text(
                'CONNECTIVITY',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: theme.text,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Bluetooth Enable Switch Tile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.card2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.line),
            ),
            child: Row(
              children: [
                Icon(
                  _bluetoothEnabled ? Icons.bluetooth_rounded : Icons.bluetooth_disabled_rounded,
                  color: _bluetoothEnabled ? theme.accent : theme.textFaint,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Bluetooth',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.text,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _bluetoothEnabled,
                  onChanged: _toggleBluetooth,
                  activeThumbColor: theme.accent,
                  activeTrackColor: theme.accent.withValues(alpha: 0.3),
                  inactiveThumbColor: theme.textDim,
                  inactiveTrackColor: theme.line,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: _bluetoothEnabled
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active connection details
                      if (widget.phoneConnected) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CONNECTED DEVICE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: theme.accent,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.phone_android_rounded, color: theme.text, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _pairedDeviceName ?? 'Connected Phone',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: theme.text,
                                        fontFamily: 'Space Grotesk',
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _disconnect,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      foregroundColor: Colors.redAccent,
                                    ),
                                    child: const Text(
                                      'DISCONNECT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Space Grotesk',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      
                      // Radar / Scan State
                      if (_isScanning) ...[
                        const Spacer(),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RadarScanner(theme: theme),
                              const SizedBox(height: 12),
                              Text(
                                'Searching for nearby phones...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textDim,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ] else ...[
                        // Available Devices Header & List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AVAILABLE PHONES',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.textDim,
                                letterSpacing: 1.0,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                            if (!widget.phoneConnected)
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                color: theme.textDim,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _startScan,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: _nearbyDevices.isEmpty
                              ? Center(
                                  child: Text(
                                    'No devices found',
                                    style: TextStyle(color: theme.textFaint, fontFamily: 'Space Grotesk'),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _nearbyDevices.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final device = _nearbyDevices[index];
                                    final isConnecting = _connectingDeviceName == device.name;
                                    
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      color: theme.card2,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: theme.line),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: (widget.phoneConnected || isConnecting)
                                            ? null
                                            : () => _handleDeviceTap(device),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.phone_android_rounded,
                                                color: widget.phoneConnected
                                                    ? theme.textFaint
                                                    : theme.textDim,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  device.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: widget.phoneConnected
                                                        ? theme.textFaint
                                                        : theme.text,
                                                    fontFamily: 'Space Grotesk',
                                                  ),
                                                ),
                                              ),
                                              if (isConnecting)
                                                SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
                                                  ),
                                                )
                                              else if (widget.phoneConnected)
                                                const SizedBox()
                                              else
                                                Icon(
                                                  Icons.signal_cellular_alt_rounded,
                                                  color: theme.textFaint,
                                                  size: 14,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ],
                  )
                : Center(
                    child: Text(
                      'Enable Bluetooth to search for devices',
                      style: TextStyle(color: theme.textFaint, fontFamily: 'Space Grotesk'),
                    ),
                  ),
          ),
          
          // Action button to open native system settings
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              icon: Icon(Icons.settings_bluetooth_rounded, size: 16, color: theme.accent),
              label: Text(
                'OPEN SYSTEM SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: theme.text,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _bluetoothService.openBluetoothSettings();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarScanner extends StatefulWidget {
  final HudTheme theme;
  const _RadarScanner({required this.theme});

  @override
  State<_RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<_RadarScanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (index) {
                final progress = (_controller.value + index / 3.0) % 1.0;
                return Container(
                  width: 15 + progress * 65,
                  height: 15 + progress * 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.theme.accent.withValues(alpha: (1.0 - progress) * 0.15),
                    border: Border.all(
                      color: widget.theme.accent.withValues(alpha: (1.0 - progress) * 0.4),
                      width: 1.5,
                    ),
                  ),
                );
              }),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.theme.accent,
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.accent.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
