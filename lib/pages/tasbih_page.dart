import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
    HapticFeedback.lightImpact();
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_count',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _increment,
                child: const Text('Tap'),
              ),
              const SizedBox(width: 24),
              OutlinedButton(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Counter'),
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
}
