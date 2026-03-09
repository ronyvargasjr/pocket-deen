import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/arabic_text.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class DuasPage extends StatefulWidget {
  const DuasPage({super.key});

  @override
  State<DuasPage> createState() => _DuasPageState();
}

class _DuasPageState extends State<DuasPage> {
  Map<String, List<dynamic>> _duas = {};
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadDuas();
    _loadFavorites();
  }

  Future<void> _loadDuas() async {
    final String data = await rootBundle.loadString('assets/data/duas.json');
    final decoded = json.decode(data) as Map<String, dynamic>;
    setState(() {
      _duas = decoded.map((k, v) => MapEntry(k, v as List<dynamic>));
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorite_duas')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String dua) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(dua)) {
        _favorites.remove(dua);
      } else {
        _favorites.add(dua);
      }
      prefs.setStringList('favorite_duas', _favorites.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_duas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _duas.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ...entry.value.map((dua) => Card(
                  color: AppTheme.cardBg,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: ArabicText(
                      dua['arabic'],
                      fontSize: 22,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dua['english'],
                        style: AppTheme.cardText3Style,
                      ),
                    ),
                    trailing: FavoriteButton(
                      isFavorite: _favorites.contains(dua['arabic']),
                      onTap: () => _toggleFavorite(dua['arabic']),
                    ),
                  ),
                )),
          ],
        );
      }).toList(),
    );
  }
}
