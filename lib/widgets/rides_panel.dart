import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import '../models/hud_app_state.dart';

enum RidesSection {
  statistics,
  mileage,
}

/// Split-screen Rides Hub featuring comprehensive Ride Statistics and Mileage Tracking.
class RidesPanel extends StatefulWidget {
  final HudTheme theme;
  final List<Map<String, dynamic>>? recentRides;
  final List<Map<String, dynamic>>? fuelRecords;
  final double? currentOdoKm;
  final bool phoneConnected;
  final VoidCallback? onPhoneTap;
  final void Function(double liters, double lastOdo, double currentOdo)? onRecordRefuel;

  const RidesPanel({
    super.key,
    required this.theme,
    this.recentRides,
    this.fuelRecords,
    this.currentOdoKm,
    this.phoneConnected = false,
    this.onPhoneTap,
    this.onRecordRefuel,
  });

  @override
  State<RidesPanel> createState() => _RidesPanelState();
}

class _RidesPanelState extends State<RidesPanel> {
  RidesSection _activeSection = RidesSection.statistics;
  bool _isSyncing = false;

  // Fuel logging input state
  double _inputLiters = 11.5;
  late List<Map<String, dynamic>> _localFuelRecords;

  @override
  void initState() {
    super.initState();
    _localFuelRecords = List<Map<String, dynamic>>.from(
      widget.fuelRecords ?? HudAppState.defaultFuelRecords,
    );
  }

  @override
  void didUpdateWidget(covariant RidesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fuelRecords != null && widget.fuelRecords != oldWidget.fuelRecords) {
      _localFuelRecords = List<Map<String, dynamic>>.from(widget.fuelRecords!);
    }
  }

  void _sendDataToPhone({required String dataLabel}) {
    setState(() => _isSyncing = true);

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: widget.theme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '$dataLabel successfully synced to phone via Bluetooth!',
                style: const TextStyle(fontFamily: 'Space Grotesk'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: widget.theme.surfaceContainerHigh,
        ),
      );
    });
  }

  void _handleRecordRefuel() {
    final systemOdo = widget.currentOdoKm ?? 14820.0;
    final lastOdo = _localFuelRecords.isNotEmpty
        ? (_localFuelRecords.first['currentOdoKm'] as num).toDouble()
        : (systemOdo - 260.0);

    final distanceTraveled = (systemOdo - lastOdo).clamp(1.0, 9999.0);
    final kmPerLiter = double.parse((distanceTraveled / _inputLiters).toStringAsFixed(1));

    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    final dateStr = 'Today, $hour:$min $amPm';

    final newEntry = {
      'id': 'fuel_${DateTime.now().millisecondsSinceEpoch}',
      'date': dateStr,
      'lastOdoKm': lastOdo,
      'currentOdoKm': systemOdo,
      'liters': _inputLiters,
      'kmPerLiter': kmPerLiter,
    };

    setState(() {
      _localFuelRecords = [newEntry, ..._localFuelRecords];
    });

    if (widget.onRecordRefuel != null) {
      widget.onRecordRefuel!(_inputLiters, lastOdo, systemOdo);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Refuel of ${_inputLiters.toStringAsFixed(1)} L recorded! Efficiency: $kmPerLiter km/L',
          style: const TextStyle(fontFamily: 'Space Grotesk'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: widget.theme.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          // 1. Top Header
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
                    child: Icon(Icons.sports_motorsports_rounded, size: 20, color: theme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rides Hub & Telemetry',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Text(
                        'Performance trip analytics, lifetime stats & consecutive refuel logs',
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
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hub_rounded, size: 13, color: theme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Automotive Telemetry Engine',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.onSurface, fontFamily: 'Space Grotesk'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Split Screen Layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Navigation Sidebar
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      _buildMenuCategory(
                        section: RidesSection.statistics,
                        icon: Icons.insights_rounded,
                        label: 'Ride Statistics',
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCategory(
                        section: RidesSection.mileage,
                        icon: Icons.local_gas_station_rounded,
                        label: 'Mileage Tracking',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Right Detail Content Panel
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
                      child: _activeSection == RidesSection.statistics
                          ? _buildStatisticsContent(theme)
                          : _buildMileageContent(theme),
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
    required RidesSection section,
    required IconData icon,
    required String label,
    required HudTheme theme,
  }) {
    final isSelected = _activeSection == section;

    return GestureDetector(
      onTap: () => setState(() => _activeSection = section),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.surfaceContainerHigh : theme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.primary.withValues(alpha: 0.5)
                  : theme.outlineVariant.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? theme.primary : theme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? theme.onSurface : theme.onSurfaceVariant,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Section 1: Ride Statistics
  Widget _buildStatisticsContent(HudTheme theme) {
    final rides = widget.recentRides ?? HudAppState.defaultRecentRides;

    double totalKm = 0;
    int maxTopSpeed = 0;
    int totalMinutes = 0;

    for (final ride in rides) {
      totalKm += (ride['distanceKm'] as num? ?? 0).toDouble();
      final top = (ride['topSpeedKm'] as num? ?? 0).toInt();
      if (top > maxTopSpeed) maxTopSpeed = top;

      final durStr = ride['duration']?.toString() ?? '';
      if (durStr.contains('h')) {
        final parts = durStr.split('h');
        final h = int.tryParse(parts[0].trim()) ?? 0;
        final m = int.tryParse(parts.length > 1 ? parts[1].replaceAll('m', '').trim() : '0') ?? 0;
        totalMinutes += (h * 60) + m;
      } else {
        totalMinutes += int.tryParse(durStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
    }

    final totalHours = totalMinutes ~/ 60;
    final remMins = totalMinutes % 60;
    final formattedTime = totalHours > 0 ? '${totalHours}h ${remMins}m' : '$totalMinutes min';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading & Send to phone button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, size: 16, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ride Statistics & History',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : () => _sendDataToPhone(dataLabel: 'Ride statistics'),
              icon: _isSyncing
                  ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: theme.onPrimary))
                  : Icon(Icons.phone_android_rounded, size: 14, color: theme.onPrimary),
              label: Text(
                _isSyncing ? 'Syncing...' : 'Send Data to Phone',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4 Summary Metrics Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'TOTAL DISTANCE',
                value: '${totalKm.toStringAsFixed(1)} km',
                icon: Icons.alt_route_rounded,
                isAccent: true,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'RIDE TIME',
                value: formattedTime,
                icon: Icons.timer_outlined,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'ALL-TIME TOP',
                value: '$maxTopSpeed km/h',
                icon: Icons.speed_rounded,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'TOTAL RIDES',
                value: '${rides.length} trips',
                icon: Icons.sports_motorsports_rounded,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Header for Recent Trips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT COMPLETED TRIPS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: theme.outline,
                fontFamily: 'Space Grotesk',
              ),
            ),
            Text(
              '${rides.length} recorded',
              style: TextStyle(
                fontSize: 9.5,
                color: theme.outline,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // List of recent rides
        ...rides.map((ride) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildRideItemCard(ride, theme: theme, isLatest: ride == rides.first),
            )),
      ],
    );
  }

  // Section 2: Mileage Tracking
  Widget _buildMileageContent(HudTheme theme) {
    final systemOdo = widget.currentOdoKm ?? 14820.0;
    final lastOdo = _localFuelRecords.isNotEmpty
        ? (_localFuelRecords.first['currentOdoKm'] as num).toDouble()
        : (systemOdo - 260.0);

    // Calculate average mileage from records
    double sumMileage = 0;
    double sumLiters = 0;
    double sumDistance = 0;

    for (final record in _localFuelRecords) {
      final l = (record['liters'] as num? ?? 0).toDouble();
      final kmPerL = (record['kmPerLiter'] as num? ?? 0).toDouble();
      final d = ((record['currentOdoKm'] as num? ?? 0) - (record['lastOdoKm'] as num? ?? 0)).toDouble();
      sumMileage += kmPerL;
      sumLiters += l;
      sumDistance += d;
    }

    final avgMileage = _localFuelRecords.isNotEmpty
        ? (sumMileage / _localFuelRecords.length).toStringAsFixed(1)
        : '23.8';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with "Send to Phone"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_gas_station_rounded, size: 16, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  'Mileage & Fuel Log',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : () => _sendDataToPhone(dataLabel: 'Mileage & refuel history'),
              icon: _isSyncing
                  ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: theme.onPrimary))
                  : Icon(Icons.phone_android_rounded, size: 14, color: theme.onPrimary),
              label: Text(
                _isSyncing ? 'Syncing...' : 'Send Data to Phone',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Summary Metric Row
        Row(
          children: [
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'AVG FUEL ECONOMY',
                value: '$avgMileage km/L',
                icon: Icons.eco_rounded,
                isAccent: true,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'TOTAL FUEL LOGGED',
                value: '${sumLiters.toStringAsFixed(1)} L',
                icon: Icons.water_drop_outlined,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'REFUEL DISTANCE',
                value: '${sumDistance.toStringAsFixed(0)} km',
                icon: Icons.route_rounded,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 1. Refuel Input Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
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
                      Icon(Icons.add_circle_outline_rounded, size: 15, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Record Refuel Entry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'ODO: ${systemOdo.toStringAsFixed(0)} km',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Telemetry comparison line: Last ODO -> Current ODO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last Refuel: ${lastOdo.toStringAsFixed(0)} km',
                      style: TextStyle(fontSize: 10.5, color: theme.outline, fontFamily: 'Space Grotesk'),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: theme.outline),
                    Text(
                      'Current ODO: ${systemOdo.toStringAsFixed(0)} km',
                      style: TextStyle(fontSize: 10.5, color: theme.onSurface, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${(systemOdo - lastOdo).toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: theme.primary, fontFamily: 'Space Grotesk'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Volume Stepper & "Record Refuel" Action Row
              Row(
                children: [
                  // Liters Stepper
                  Container(
                    decoration: BoxDecoration(
                      color: theme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_inputLiters > 1.0) {
                              setState(() => _inputLiters = double.parse((_inputLiters - 0.5).toStringAsFixed(1)));
                            }
                          },
                          icon: const Icon(Icons.remove_rounded, size: 16),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: theme.onSurface,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${_inputLiters.toStringAsFixed(1)} L',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.onSurface,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_inputLiters < 30.0) {
                              setState(() => _inputLiters = double.parse((_inputLiters + 0.5).toStringAsFixed(1)));
                            }
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: theme.onSurface,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Quick presets
                  _buildQuickVolumeChip('+1 L', 1.0, theme),
                  const SizedBox(width: 6),
                  _buildQuickVolumeChip('+2 L', 2.0, theme),
                  const SizedBox(width: 6),
                  _buildQuickVolumeChip('Tank 13.5L', 13.5, theme, isFull: true),

                  const Spacer(),

                  // Record Refuel Button
                  ElevatedButton.icon(
                    onPressed: _handleRecordRefuel,
                    icon: const Icon(Icons.local_gas_station_rounded, size: 15),
                    label: const Text(
                      'Record Refuel',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Refuel History Log Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CONSECUTIVE REFUEL RECORDS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: theme.outline,
                fontFamily: 'Space Grotesk',
              ),
            ),
            Text(
              'Showing last 5 • All records in phone app',
              style: TextStyle(
                fontSize: 9.5,
                color: theme.outline,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // List of last 5 refuels
        ..._localFuelRecords.take(5).map((record) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildFuelRecordCard(record, theme: theme, isLatest: record == _localFuelRecords.first),
            )),
      ],
    );
  }

  Widget _buildQuickVolumeChip(String label, double addAmount, HudTheme theme, {bool isFull = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isFull) {
            _inputLiters = addAmount;
          } else {
            _inputLiters = double.parse((_inputLiters + addAmount).toStringAsFixed(1));
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: theme.onSurfaceVariant,
            fontFamily: 'Space Grotesk',
          ),
        ),
      ),
    );
  }

  Widget _buildFuelRecordCard(Map<String, dynamic> record, {required HudTheme theme, bool isLatest = false}) {
    final date = record['date']?.toString() ?? '';
    final lastOdo = (record['lastOdoKm'] as num? ?? 0).toDouble();
    final currentOdo = (record['currentOdoKm'] as num? ?? 0).toDouble();
    final liters = (record['liters'] as num? ?? 0).toDouble();
    final kmPerL = (record['kmPerLiter'] as num? ?? 0).toDouble();
    final tripDist = currentOdo - lastOdo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLatest ? theme.primary.withValues(alpha: 0.35) : theme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Gas Pump Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isLatest ? theme.primaryContainer : theme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_gas_station_rounded,
              size: 18,
              color: isLatest ? theme.primary : theme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),

          // Date & ODO range
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: theme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LATEST',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: theme.onPrimaryContainer,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'ODO: ${lastOdo.toStringAsFixed(0)} → ${currentOdo.toStringAsFixed(0)} km',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.outline,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),

          // Telemetry Badges
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTelemetryBadge(
                  label: 'TRIP',
                  value: '${tripDist.toStringAsFixed(0)} km',
                  theme: theme,
                ),
                _buildTelemetryBadge(
                  label: 'FUEL',
                  value: '${liters.toStringAsFixed(1)} L',
                  theme: theme,
                ),
                _buildTelemetryBadge(
                  label: 'MILEAGE',
                  value: '$kmPerL km/L',
                  isAccent: true,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetricCard({
    required String title,
    required String value,
    required IconData icon,
    bool isAccent = false,
    required HudTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAccent ? theme.primary.withValues(alpha: 0.4) : theme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isAccent ? theme.primary : theme.outline,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              Icon(
                icon,
                size: 14,
                color: isAccent ? theme.primary : theme.outline,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideItemCard(Map<String, dynamic> ride, {required HudTheme theme, bool isLatest = false}) {
    final title = ride['title'] ?? 'Ride';
    final date = ride['date'] ?? '';
    final duration = ride['duration'] ?? '';
    final distanceKm = (ride['distanceKm'] as num? ?? 0).toDouble();
    final avgSpeed = (ride['avgSpeedKm'] as num? ?? 0).toInt();
    final topSpeed = (ride['topSpeedKm'] as num? ?? 0).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLatest ? theme.primary.withValues(alpha: 0.35) : theme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isLatest ? theme.primaryContainer : theme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_motorsports_rounded,
              size: 18,
              color: isLatest ? theme.primary : theme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: theme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LATEST',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: theme.onPrimaryContainer,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.outline,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTelemetryBadge(
                  label: 'DIST',
                  value: '${distanceKm.toStringAsFixed(1)} km',
                  theme: theme,
                ),
                _buildTelemetryBadge(
                  label: 'TIME',
                  value: duration,
                  theme: theme,
                ),
                _buildTelemetryBadge(
                  label: 'AVG SPD',
                  value: '$avgSpeed km/h',
                  theme: theme,
                ),
                _buildTelemetryBadge(
                  label: 'TOP SPD',
                  value: '$topSpeed km/h',
                  isAccent: true,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryBadge({
    required String label,
    required String value,
    bool isAccent = false,
    required HudTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAccent ? theme.primary.withValues(alpha: 0.3) : theme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: isAccent ? theme.primary : theme.outline,
              letterSpacing: 0.8,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}
