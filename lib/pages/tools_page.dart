import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  // Tool definitions
  final List<Map<String, dynamic>> _tools = const [
    {
      'key': 'qibla',
      'title': 'Qibla Compass',
      'description': 'Find the direction of the Qibla for prayer.',
      'icon': Icons.explore,
    },
    {
      'key': 'tasbih',
      'title': 'Tasbih Counter',
      'description': 'Count your dhikr and tasbih easily.',
      'icon': Icons.fingerprint,
    },
  ];

  Set<String> _favoriteTools = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteTools();
  }

  Future<void> _loadFavoriteTools() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteTools = prefs.getStringList('favorite_tools')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavoriteTool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteTools.contains(key)) {
        _favoriteTools.remove(key);
      } else {
        _favoriteTools.add(key);
      }
      prefs.setStringList('favorite_tools', _favoriteTools.toList());
    });
  }

  void _navigateToTool(BuildContext context, String key) {
    if (key == 'qibla') {
      Navigator.of(context).pushNamed('/qibla');
    } else if (key == 'tasbih') {
      Navigator.of(context).pushNamed('/tasbih');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tools.length,
      itemBuilder: (context, index) {
        final tool = _tools[index];
        return Card(
          color: AppTheme.cardBg,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(tool['icon'], size: 36, color: Theme.of(context).colorScheme.primary),
            title: Text(tool['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(tool['description']),
            trailing: IconButton(
              icon: Icon(_favoriteTools.contains(tool['key']) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              tooltip: _favoriteTools.contains(tool['key']) ? 'Unfavorite' : 'Favorite',
              onPressed: () => _toggleFavoriteTool(tool['key']),
            ),
            onTap: () => _navigateToTool(context, tool['key']),
          ),
        );
      },
    );
  }
}
