import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pocket_deen/pages/home_page.dart';
import 'package:pocket_deen/pages/qibla_page.dart';
import 'package:pocket_deen/pages/tasbih_page.dart';
import 'package:pocket_deen/utils/app_theme.dart';
import 'package:pocket_deen/utils/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:pocket_deen/utils/theme_provider.dart';

void main() {
  runApp(const PocketDeenApp());
}

class PocketDeenApp extends StatelessWidget {
  const PocketDeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Pocket Deen',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            home: const HomePage(),
            routes: {
              '/qibla': (context) => const QiblaPage(),
              '/tasbih': (context) => const TasbihPage(),
            },
          );
        },
      ),
    );
  }
}
