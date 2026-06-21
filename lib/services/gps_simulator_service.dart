import 'dart:async';

class GpsSimulatorData {
  final int speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double tripDistanceKm;
  final bool gpsConnected;

  const GpsSimulatorData({
    required this.speed,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.tripDistanceKm,
    required this.gpsConnected,
  });
}

class GpsSimulatorService {
  Timer? _timer;

  int _speed = 0;
  double _latitude = 17.3850;
  double _longitude = 78.4867;
  double _heading = 0;
  double _tripDistanceKm = 0;

  void start({required void Function(GpsSimulatorData data) onData}) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _speed += 4;

      if (_speed > 92) {
        _speed = 0;
      }

      _heading += 7;

      if (_heading >= 360) {
        _heading = 0;
      }

      _latitude += 0.00008;
      _longitude += 0.00005;
      _tripDistanceKm += _speed / 3600;

      onData(
        GpsSimulatorData(
          speed: _speed,
          latitude: _latitude,
          longitude: _longitude,
          heading: _heading,
          tripDistanceKm: _tripDistanceKm,
          gpsConnected: true,
        ),
      );
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
