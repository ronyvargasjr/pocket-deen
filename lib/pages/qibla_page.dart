
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  double _direction = 0;
  double? _qiblaDirection;
  StreamSubscription<MagnetometerEvent>? _compassStream;
  // ignore: unused_field
  Position? _position;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _compassStream = SensorsPlatform.instance.magnetometerEvents.listen((event) {
      setState(() {
        _direction = math.atan2(event.y, event.x) * (180 / math.pi);
      });
    });
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _position = pos;
      _qiblaDirection = _calculateQiblaDirection(pos.latitude, pos.longitude);
    });
  }

  double _calculateQiblaDirection(double lat, double lng) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    final double dLng = (kaabaLng - lng) * math.pi / 180;
    final double y = math.sin(dLng) * math.cos(kaabaLat * math.pi / 180);
    final double x = math.cos(lat * math.pi / 180) * math.sin(kaabaLat * math.pi / 180) -
        math.sin(lat * math.pi / 180) * math.cos(kaabaLat * math.pi / 180) * math.cos(dLng);
    final double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  @override
  void dispose() {
    _compassStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _qiblaDirection == null
          ? const Text('Enable location to show Qibla direction')
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green, width: 4),
                      ),
                    ),
                    Transform.rotate(
                      angle: ((_direction - _qiblaDirection!) * math.pi / 180),
                      child: Icon(Icons.navigation, size: 120, color: Colors.green[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Qibla direction: ${_qiblaDirection!.toStringAsFixed(1)}°'),
              ],
            ),
    );
  }
}
