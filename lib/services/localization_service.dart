import 'package:geogame/util.dart';

class Yazi {
  static Map<String, dynamic>? _localizedStrings;
  static String _currentLanguage = 'English';

  static Future<void> loadDil(String dilKodu) async {
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
      dilDegistir();
      return '⚠️ Dil dosyası yükleniyor...';
    }

    if (_localizedStrings!.containsKey(key)) {
      final metin = _localizedStrings?[key]?[_currentLanguage] ?? '';
      return metin.replaceAll('\\n', '\n');
    }

    return '⚠️ $key bulunamadı';
  }

  static Future<void> dilDegistir() async {
    if (secilenDil.isEmpty)
      secilenDil = diltercihi == 'tr' ? "Türkçe" : "English";
    //await loadDil(secilenDil);
    await Yazi.loadDil(secilenDil).then((_) {
      navBarItems = [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: Text(Yazi.get('navigasyonbar1')),
          selectedColor: Colors.purple,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.leaderboard),
          title: Text(Yazi.get('navigasyonbar2')),
          selectedColor: Colors.pink,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.person),
          title: Text(Yazi.get('navigasyonbar3')),
          selectedColor: Colors.teal,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.settings),
          title: Text(Yazi.get('navigasyonbar4')),
          selectedColor: Colors.orange,
        ),
      ];
    });
    isEnglish = (secilenDil != 'Türkçe');
  }
}

final List<String> diller = ['Türkçe', 'English'];