import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/arabic_text.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> _phrases = [];
  Set<String> _favorites = {};
  Set<String> _favoriteTools = {};

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

  @override
  void initState() {
    super.initState();
    _loadPhrases();
    _loadFavorites();
    _loadFavoriteTools();
  }

  Future<void> _loadPhrases() async {
    final String data = await rootBundle.loadString('assets/data/phrases.json');
    setState(() {
      _phrases = json.decode(data);
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorite_phrases')?.toSet() ?? {};
    });
  }

  Future<void> _loadFavoriteTools() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteTools = prefs.getStringList('favorite_tools')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(phrase)) {
        _favorites.remove(phrase);
      } else {
        _favorites.add(phrase);
      }
      prefs.setStringList('favorite_phrases', _favorites.toList());
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

  @override
  Widget build(BuildContext context) {
    final favoritePhrases = _phrases.where((p) => _favorites.contains(p['arabic'])).toList();
    final favoriteTools = _tools.where((t) => _favoriteTools.contains(t['key'])).toList();
    if (favoritePhrases.isEmpty && favoriteTools.isEmpty) {
      return const Center(child: Text('No favorites yet.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Favorite tools
        ...favoriteTools.map((tool) => Card(
              color: AppTheme.cardBg,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(tool['icon'], size: 36, color: Theme.of(context).colorScheme.primary),
                title: Text(tool['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(tool['description']),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Unfavorite',
                  onPressed: () => _toggleFavoriteTool(tool['key']),
                ),
                onTap: () {
                  if (tool['key'] == 'qibla') {
                    Navigator.of(context).pushNamed('/qibla');
                  } else if (tool['key'] == 'tasbih') {
                    Navigator.of(context).pushNamed('/tasbih');
                  }
                },
              ),
            )),
        // Favorite phrases
        ...favoritePhrases.map((phrase) => Card(
              color: AppTheme.cardBg,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ArabicText(
                            phrase['arabic'],
                            fontSize: 24,
                            align: TextAlign.left,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.black,),
                          tooltip: 'Copy Arabic',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: phrase['arabic']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied Arabic to clipboard!')),
                            );
                          },
                        ),
                      ],
                    ),
                    if (phrase['transliteration'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                phrase['transliteration'],
                                style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blueGrey),
                              tooltip: 'Copy Transliteration',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: phrase['transliteration']));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied transliteration to clipboard!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              phrase['english'],
                              style: AppTheme.cardText3Style,
                            ),
                          ),
                          FavoriteButton(
                            isFavorite: _favorites.contains(phrase['arabic']),
                            onTap: () => _toggleFavorite(phrase['arabic']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
