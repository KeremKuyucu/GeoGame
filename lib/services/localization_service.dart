import 'package:geogame/util.dart';

import '../data/app_context.dart';
import '../data/bottomBar.dart';

class Localization {
  static Map<String, dynamic>? _localizedStrings;
  static String _currentLanguage = 'English';

  static Future<void> loadLocalization(String dilKodu) async {
    if (_currentLanguage == dilKodu && _localizedStrings != null) {
      return; // Dil zaten yüklü, ekstra işlem yapma
    }

    try {
      String jsonString = await rootBundle.loadString('assets/dil.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      if (jsonMap['Veriler'] != null) {
        _localizedStrings = jsonMap['Veriler'];
        _currentLanguage = dilKodu;
      } else {
        throw Exception('JSON dosyasında "Veriler" anahtarı bulunamadı!');
      }
    } catch (e) {
      _localizedStrings = {};
    }
  }

  static String get(String key) {
    if (_localizedStrings == null) {
      languageSwitch();
      return '⚠️ Dil dosyası yükleniyor...';
    }

    if (_localizedStrings!.containsKey(key)) {
      final metin = _localizedStrings?[key]?[_currentLanguage] ?? '';
      return metin.replaceAll('\\n', '\n');
    }

    return '⚠️ $key bulunamadı';
  }

  static Future<void> languageSwitch() async {
    if (AppState.settings.language.isEmpty)
      AppState.settings.language = AppState.settings.languagePref == 'tr' ? "Türkçe" : "English";
    await Localization.loadLocalization(AppState.settings.language).then((_) {
      navBarItems = [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: Text(Localization.get('navigasyonbar1')),
          selectedColor: Colors.purple,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.leaderboard),
          title: Text(Localization.get('navigasyonbar2')),
          selectedColor: Colors.pink,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.person),
          title: Text(Localization.get('navigasyonbar3')),
          selectedColor: Colors.teal,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.settings),
          title: Text(Localization.get('navigasyonbar4')),
          selectedColor: Colors.orange,
        ),
      ];
    });
  }
}

final List<String> diller = ['Türkçe', 'English'];