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
  List<dynamic> _duas = [];
  Set<String> _favoritePhrases = {};
  Set<String> _favoriteDuas = {};
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
    _loadDuas();
    _loadFavoritePhrases();
    _loadFavoriteDuas();
    _loadFavoriteTools();
  }


  Future<void> _loadPhrases() async {
    final String data = await rootBundle.loadString('assets/data/phrases.json');
    setState(() {
      _phrases = json.decode(data);
    });
  }

  Future<void> _loadDuas() async {
    final String data = await rootBundle.loadString('assets/data/duas.json');
    final decoded = json.decode(data) as Map<String, dynamic>;
    // Flatten all duas into a single list
    final allDuas = <dynamic>[];
    decoded.forEach((_, v) {
      if (v is List) allDuas.addAll(v);
    });
    setState(() {
      _duas = allDuas;
    });
  }


  Future<void> _loadFavoritePhrases() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePhrases = prefs.getStringList('favorite_phrases')?.toSet() ?? {};
    });
  }

  Future<void> _loadFavoriteDuas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteDuas = prefs.getStringList('favorite_duas')?.toSet() ?? {};
    });
  }

  Future<void> _loadFavoriteTools() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteTools = prefs.getStringList('favorite_tools')?.toSet() ?? {};
    });
  }


  Future<void> _toggleFavoritePhrase(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoritePhrases.contains(phrase)) {
        _favoritePhrases.remove(phrase);
      } else {
        _favoritePhrases.add(phrase);
      }
      prefs.setStringList('favorite_phrases', _favoritePhrases.toList());
    });
  }

  Future<void> _toggleFavoriteDua(String dua) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteDuas.contains(dua)) {
        _favoriteDuas.remove(dua);
      } else {
        _favoriteDuas.add(dua);
      }
      prefs.setStringList('favorite_duas', _favoriteDuas.toList());
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
    final favoritePhrases = _phrases.where((p) => _favoritePhrases.contains(p['arabic'])).toList();
    final favoriteDuas = _duas.where((d) => _favoriteDuas.contains(d['arabic'])).toList();
    final favoriteTools = _tools.where((t) => _favoriteTools.contains(t['key'])).toList();
    if (favoritePhrases.isEmpty && favoriteDuas.isEmpty && favoriteTools.isEmpty) {
      return const Center(child: Text('No favorites yet.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Favorite tools
        ...favoriteTools.map((tool) => Card(
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
                          icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.onSurface,),
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
                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface),
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
                            isFavorite: _favoritePhrases.contains(phrase['arabic']),
                            onTap: () => _toggleFavoritePhrase(phrase['arabic']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        // Favorite duas
        ...favoriteDuas.map((dua) => Card(
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
                            dua['arabic'],
                            fontSize: 24,
                            align: TextAlign.left,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.onSurface,),
                          tooltip: 'Copy Arabic',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: dua['arabic']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied Arabic to clipboard!')),
                            );
                          },
                        ),
                      ],
                    ),
                    if (dua['transliteration'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                dua['transliteration'],
                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blueGrey),
                              tooltip: 'Copy Transliteration',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: dua['transliteration']));
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
                              dua['english'],
                              style: AppTheme.cardText3Style,
                            ),
                          ),
                          FavoriteButton(
                            isFavorite: _favoriteDuas.contains(dua['arabic']),
                            onTap: () => _toggleFavoriteDua(dua['arabic']),
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
