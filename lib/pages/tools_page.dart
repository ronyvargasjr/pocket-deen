import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_deen/pages/qibla_page.dart';
import 'package:pocket_deen/pages/tasbih_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key, this.titleNotifier, this.canPopNotifier, this.navigatorKey});

  /// Optionally notify parent of the current sub-page title.
  final ValueNotifier<String>? titleNotifier;
  /// Optionally notify parent whether the nested navigator can pop.
  final ValueNotifier<bool>? canPopNotifier;
  /// Key to allow parent to control the nested navigator (e.g. pop).
  final GlobalKey<NavigatorState>? navigatorKey;

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
    Navigator.of(context).pushNamed('/$key');
  }

  void _notifyTitle(String title, bool canPop) {
    widget.titleNotifier?.value = title;
    widget.canPopNotifier?.value = canPop;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      observers: [
        _ToolsRouteObserver(_notifyTitle),
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/qibla') {
          return MaterialPageRoute(
            builder: (_) => const QiblaPage(embedded: true),
            settings: settings,
          );
        }
        if (settings.name == '/tasbih') {
          return MaterialPageRoute(
            builder: (_) => const TasbihPage(embedded: true),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (ctx) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tools.length,
            itemBuilder: (context, index) {
              final tool = _tools[index];
              return Card(
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
          ),
        );
      },
    );
  }
}

/// Watches the nested tools navigator and reports the current page title/canPop to the parent.
class _ToolsRouteObserver extends NavigatorObserver {
  _ToolsRouteObserver(this._onRouteChanged);

  final void Function(String title, bool canPop) _onRouteChanged;

  static const _titles = {
    '/qibla': 'Qibla Compass',
    '/tasbih': 'Tasbih Counter',
  };

  void _notify(Route<dynamic> route, bool canPop) {
    final title = _titles[route.settings.name] ?? 'Tools';
    _onRouteChanged(title, canPop);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify(route, previousRoute != null);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _notify(previousRoute, false);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _notify(newRoute, false);
  }
}
