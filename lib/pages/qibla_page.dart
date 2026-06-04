
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}


class _QiblaPageState extends State<QiblaPage> {
  double _heading = 0;
  double? _qiblaDirection;
  StreamSubscription<CompassEvent>? _compassStream;
  bool _locationServiceEnabled = true;
  LocationPermission? _permission;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _compassStream = FlutterCompass.events!.listen((CompassEvent event) {
      if (event.heading != null) {
        setState(() {
          _heading = event.heading!;
        });
      }
    });
  }

  Future<void> _initLocation() async {
    setState(() {
      _isRequesting = true;
    });
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    setState(() {
      _locationServiceEnabled = serviceEnabled;
      _permission = permission;
      _isRequesting = false;
    });
    if (!serviceEnabled) return;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      setState(() {
        _permission = permission;
      });
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    final coordinates = Coordinates(pos.latitude, pos.longitude);
    final qibla = Qibla(coordinates);
    setState(() {
      _qiblaDirection = qibla.direction;
    });
  }

  @override
  void dispose() {
    _compassStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      child: Center(
        child: _qiblaDirection == null
            ? _buildLocationPrompt(context)
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
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Colors.green, width: 4),
                        ),
                      ),
                      Transform.rotate(
                        angle: (() {
                          double a = (_qiblaDirection! - _heading) % 360;
                          if (a > 180) a -= 360;
                          return a * math.pi / 180;
                        })(),
                        child: Icon(Icons.navigation, size: 120, color: Colors.green[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Qibla direction: ${_qiblaDirection!.toStringAsFixed(1)}° from North'),
                ],
              ),
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: body,
    );
  }

  Widget _buildLocationPrompt(BuildContext context) {
    String message = '';
    Widget? actionButton;
    if (!_locationServiceEnabled) {
      message = 'Location services are disabled.';
      actionButton = ElevatedButton(
        onPressed: () async {
          await Geolocator.openLocationSettings();
        },
        child: const Text('Open Location Settings'),
      );
    } else if (_permission == LocationPermission.denied) {
      message = 'Location permission is denied.';
      actionButton = ElevatedButton(
        onPressed: () async {
          await Geolocator.requestPermission();
          _initLocation();
        },
        child: const Text('Request Permission'),
      );
    } else if (_permission == LocationPermission.deniedForever) {
      message = 'Location permission is permanently denied.';
      actionButton = ElevatedButton(
        onPressed: () async {
          await Geolocator.openAppSettings();
        },
        child: const Text('Open App Settings'),
      );
    } else if (_isRequesting) {
      message = 'Checking location...';
    } else {
      message = 'Enable location to show Qibla direction.';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            message,
            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
        if (actionButton != null) ...[
          const SizedBox(height: 16),
          actionButton,
        ],
      ],
    );
  }
}
