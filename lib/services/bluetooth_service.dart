import 'package:flutter/services.dart';

class BluetoothDeviceInfo {
  final String name;
  final String address;
  final bool isPaired;
  final int rssi;

  const BluetoothDeviceInfo({
    required this.name,
    required this.address,
    this.isPaired = false,
    this.rssi = -60,
  });
}

class BluetoothService {
  static const _channel = MethodChannel('bike_hud/music');

  Future<void> openBluetoothSettings() async {
    try {
      await _channel.invokeMethod('openBluetoothSettings');
    } catch (_) {}
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      final bool enabled = await _channel.invokeMethod('isBluetoothEnabled');
      return enabled;
    } catch (_) {
      return true; // Fallback for simulation
    }
  }

  Future<bool> isBluetoothConnected() async {
    try {
      final bool connected = await _channel.invokeMethod('isBluetoothConnected');
      return connected;
    } catch (_) {
      return false; // Fallback for simulation
    }
  }

  List<BluetoothDeviceInfo> getMockAvailableDevices() {
    return const [
      BluetoothDeviceInfo(name: 'iPhone 15 Pro', address: '8C:3B:AD:4E:91:0A', rssi: -54),
      BluetoothDeviceInfo(name: 'Pixel 8 Pro', address: '4F:E2:81:7A:23:BC', rssi: -62),
      BluetoothDeviceInfo(name: 'Galaxy S24 Ultra', address: 'AA:11:BB:22:CC:33', rssi: -71),
      BluetoothDeviceInfo(name: 'OnePlus 12', address: 'D4:F5:E6:A7:B8:C9', rssi: -85),
    ];
  }
}
