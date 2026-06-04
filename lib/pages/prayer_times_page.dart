import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../utils/app_theme.dart';
import 'package:adhan/adhan.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  // ignore: unused_field
  Position? _position;
  Map<String, String>? _prayerTimes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndTimes();
  }

  Future<void> _fetchLocationAndTimes() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _loading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _loading = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _position = pos;
      });

      // Calculate prayer times using adhan_dart
      final coordinates = Coordinates(pos.latitude, pos.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);

      setState(() {
        _prayerTimes = {
          'Fajr': _formatTime(prayerTimes.fajr),
          'Dhuhr': _formatTime(prayerTimes.dhuhr),
          'Asr': _formatTime(prayerTimes.asr),
          'Maghrib': _formatTime(prayerTimes.maghrib),
          'Isha': _formatTime(prayerTimes.isha),
        };
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _prayerTimes = null;
        _loading = false;
      });
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final local = dt.toLocal();
    return local.hour.toString().padLeft(2, '0') + ':' + local.minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_prayerTimes == null) {
      return const Center(child: Text('Enable location to show prayer times'));
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: _prayerTimes!.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            title: Text(
              entry.key,
              style: AppTheme.cardText1Style,
            ),
            trailing: Text(
              entry.value,
              style: AppTheme.cardText2Style,
            ),
          ),
        );
      }).toList(),
    );
  }
}
