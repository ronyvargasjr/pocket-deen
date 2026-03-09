import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/arabic_text.dart';
import 'dart:convert';

class PhrasesPage extends StatefulWidget {
  const PhrasesPage({super.key});

  @override
  State<PhrasesPage> createState() => _PhrasesPageState();
}

class _PhrasesPageState extends State<PhrasesPage> {
  List<dynamic> _phrases = [];
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadPhrases();
    _loadFavorites();
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

  @override
  Widget build(BuildContext context) {
    return _phrases.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _phrases.length,
            itemBuilder: (context, index) {
              final phrase = _phrases[index];
              return Card(
                color: AppTheme.cardBg,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic row
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
                                icon: const Icon(Icons.copy, color: Colors.black),
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
              );
            },
          );
  }
}
