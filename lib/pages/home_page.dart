import 'package:flutter/material.dart';
import 'package:pocket_deen/pages/phrases_page.dart';
import 'package:pocket_deen/pages/duas_page.dart';
import 'package:pocket_deen/pages/tools_page.dart';
import 'package:pocket_deen/pages/prayer_times_page.dart';
import 'package:pocket_deen/pages/favorites_page.dart';
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

  final _toolsTitleNotifier = ValueNotifier<String>('Tools');
  final _toolsCanPopNotifier = ValueNotifier<bool>(false);
  final _toolsNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _pages = [
    const PhrasesPage(),
    const DuasPage(),
    ToolsPage(
      navigatorKey: _toolsNavigatorKey,
      titleNotifier: _toolsTitleNotifier,
      canPopNotifier: _toolsCanPopNotifier,
    ),
    const PrayerTimesPage(),
    const FavoritesPage(),
  ];

  final List<String> _baseTitles = const [
    'Islamic Phrases',
    'Daily Duas',
    'Tools',
    'Prayer Times',
    'Favorites',
  ];

  @override
  void dispose() {
    _toolsTitleNotifier.dispose();
    _toolsCanPopNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onToolsBack() {
    _toolsNavigatorKey.currentState?.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 2
            ? ValueListenableBuilder<String>(
                valueListenable: _toolsTitleNotifier,
                builder: (_, title, __) => Text(title),
              )
            : Text(_baseTitles[_currentIndex]),
        centerTitle: true,
        leading: _currentIndex == 2
            ? ValueListenableBuilder<bool>(
                valueListenable: _toolsCanPopNotifier,
                builder: (_, canPop, __) => canPop
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _onToolsBack,
                      )
                    : const SizedBox.shrink(),
              )
            : null,
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
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Prayers'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
