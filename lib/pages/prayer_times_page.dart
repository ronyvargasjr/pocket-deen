import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../utils/app_theme.dart';

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
    // Placeholder: Replace with real prayer time calculation or API
    setState(() {
      _prayerTimes = {
        'Fajr': '05:00',
        'Dhuhr': '12:30',
        'Asr': '15:45',
        'Maghrib': '18:20',
        'Isha': '19:40',
      };
      _loading = false;
    });
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
          color: AppTheme.cardBg,
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
