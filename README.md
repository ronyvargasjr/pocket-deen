# Pocket Deen

Pocket Deen is a Flutter mobile app providing daily Islamic resources for Muslims, including Islamic phrases, daily duas, Qibla compass, tasbih counter, and prayer times. The app supports Arabic and English, works offline for most features, and uses a clean, modern UI.

## Features
- Islamic Phrases (copyable, with translation)
- Daily Duas (by category)
- Qibla Compass (uses device sensor)
- Tasbih Counter (haptic feedback)
- Prayer Times (location-based)
- Favorites system
- Offline data storage
- Arabic/English support, RTL
- Card-based, minimal design

## Running the App
1. Install Flutter SDK (https://flutter.dev/docs/get-started/install)
2. Run `flutter pub get` to fetch dependencies
3. Run `flutter run` to launch the app on your device/emulator

## Folder Structure
- `lib/` - Main Dart code
- `assets/data/` - Example data for phrases and duas

## Notes
- Most features work offline. Prayer times and Qibla require location/sensor permissions.
- Replace placeholder data in `assets/data/` as needed.
