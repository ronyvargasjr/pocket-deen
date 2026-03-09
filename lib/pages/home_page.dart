import 'package:flutter/material.dart';
import 'package:pocket_deen/pages/phrases_page.dart';
import 'package:pocket_deen/pages/duas_page.dart';
import 'package:pocket_deen/pages/qibla_page.dart';
import 'package:pocket_deen/pages/tasbih_page.dart';
import 'package:pocket_deen/pages/prayer_times_page.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PhrasesPage(),
    DuasPage(),
    QiblaPage(),
    TasbihPage(),
    PrayerTimesPage(),
  ];

  final List<String> _titles = const [
    'Islamic Phrases',
    'Daily Duas',
    'Qibla Compass',
    'Tasbih Counter',
    'Prayer Times',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
              tooltip: themeProvider.themeMode == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
        physics: const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.format_quote), label: 'Phrases'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Duas'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
          BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Tasbih'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Prayers'),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
