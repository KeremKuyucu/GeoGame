import 'package:GeoGame/util.dart';
import 'package:http/http.dart' as http;

class Ulkeler {
  String bayrak, trisim, enisim, isim, baskent, kita, url;
  bool bilgi, bm; double enlem, boylam; int dosyaboyut;
  Ulkeler({
    required this.bayrak, required this.trisim, required this.enisim, required this.isim, required this.baskent, required this.kita,
    required this.url, required this.bilgi, required this.bm, required this.enlem, required this.boylam, required this.dosyaboyut,
  });
  bool ks(String yapilantahmin) {
    return yapilantahmin == trisim || yapilantahmin == isim || yapilantahmin == enisim;
  }
}
class Yazi {
  static Map<String, dynamic>? _localizedStrings;
  static String _currentLanguage = 'Türkçe';

  static Future<void> loadDil(String dilKodu) async {
    if (_currentLanguage == dilKodu && _localizedStrings != null) {
      return;
    }
    try {
      String jsonString = await rootBundle.loadString('assets/dil.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      if (jsonMap.containsKey(dilKodu)) {
        _localizedStrings = jsonMap[dilKodu];
      } else {
        _localizedStrings = {};
      }
      _currentLanguage = dilKodu;
    } catch (e) {
      print('Dosya bulunamadı veya JSON okuma hatası: $e');
      _localizedStrings = {};
    }
  }
  static String get(String key)  {
    loadDil(_currentLanguage);
    return _localizedStrings?[key] ?? '';
  }
}
class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(),
            child: Text(
              'GeoGame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              Yazi.get('sikayet'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.share, color: Color(0xFF5865F2)),
            title: Text(Yazi.get('uygpaylas')),
            onTap: () async {
              await Share.share(Yazi.get('davetpromt'));
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.instagram),
            title: Text(Yazi.get('instagram')),
            onTap: () async {
              await EasyLauncher.url(
                  url: Yazi.get('instagramurl'), mode: Mode.platformDefault);
            },
          ),
          ListTile(
            leading: Icon(Icons.public, color: Colors.red),
            title: Text(Yazi.get('website')),
            onTap: () async {
              await EasyLauncher.url(url: Yazi.get('websiteurl'));
            },
          ),
          ListTile(
            leading: FaIcon(Icons.report),
            title: Text(Yazi.get('hatabildir')),
            onTap: () async {
              await EasyLauncher.url(url: Yazi.get('hatabildirurl'));
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.github),
            title: Text(Yazi.get('github')),
            onTap: () async {
              await EasyLauncher.url(url: Yazi.get('githuburl'));
            },
          ),
          ListTile(
            leading: Icon(Icons.discord, color: Color(0xFF5865F2)),
            title: Text(Yazi.get('discord')),
            onTap: () async {
              await EasyLauncher.url(url: Yazi.get('discordurl'));
            },
          ),
          ListTile(
            leading: Icon(Icons.music_note, color: Colors.red),
            title: Text(Yazi.get('sarki')),
            onTap: () async {
              await EasyLauncher.url(url: Yazi.get('sarkiurl'));
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              Yazi.get('yapimci'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          SizedBox(height: 20), // Boşluk bırakır
        ],
      ),
    );
  }
}

bool amerikakitasi = true, asyakitasi = true, afrikakitasi = true, avrupakitasi = true, okyanusyakitasi = true, antartikakitasi = true, bmuyeligi = false, sadecebm= false, yazmamodu = true, backgroundMusicPlaying = false, darktema=true, isEnglish=false;
final List<String> diller = ['Türkçe','English','Español','Deutsch','Русский','中文','Kurdî','Français','Português','العربية'];
int mesafedogru=0, mesafeyanlis=0, bayrakdogru=0, bayrakyanlis=0, baskentdogru=0, baskentyanlis=0, mesafepuan=0, bayrakpuan=0, baskentpuan=0, toplampuan=0, selectedIndex = 0;
String name = "", secilenDil='Türkçe';
List<dynamic> users = [];
final random = Random(), dogru = AudioPlayer(), yanlis = AudioPlayer(), yenitur = AudioPlayer(), arkafon = AudioPlayer();
Future<void> playAudioFromAssetOrUrl(AudioPlayer player, String assetPath, String url) async {
  try {
    if (player.playing) {
      await player.stop();
    }
    await player.setAsset(assetPath);
    await player.play();
  } catch (e) {
    print('Error playing asset: $e');
    try {
      if (player.playing) {
        await player.stop();
      }
      await player.setUrl(url);
      await player.play();
    } catch (urlError) {
      print('Error playing audio from URL: $urlError');
    }
  }
}
Future<void> Dogru() async { await playAudioFromAssetOrUrl(dogru, 'assets/sesler/dogru.mp3', 'https://github.com/keremlolgg/GeoGame/raw/main/assets/sesler/dogru.mp3');}
Future<void> Yanlis() async { await playAudioFromAssetOrUrl(yanlis, 'assets/sesler/yanlis.mp3', 'https://github.com/keremlolgg/GeoGame/raw/main/assets/sesler/yanlis.mp3');}
Future<void> Yenitur() async { await playAudioFromAssetOrUrl(yenitur, 'assets/sesler/yenitur.mp3', 'https://github.com/keremlolgg/GeoGame/raw/main/assets/sesler/yenitur.mp3');}
Future<void> Arkafon() async {  await playAudioFromAssetOrUrl( arkafon, 'assets/sesler/arkafon.mp3', 'https://github.com/keremlolgg/GeoGame/raw/main/assets/sesler/arkafon.mp3'); arkafon.setLoopMode(LoopMode.one);}
Future<void> Arkafondurdur() async { await arkafon.stop(); }
// Fonksiyonlar
Future<void> yeniulkesec() async {
  int butonRandomNumber = random.nextInt(4);
  Set<int> selectedIndices = {};

  for (int i = 0; i < 4; i++) {
    int randomNumber;
    if(!sadecebm){
      do {
        randomNumber = random.nextInt(ulke.length);
      } while (((!amerikakitasi && ulke[randomNumber].kita == "Americas") ||
          (!asyakitasi && ulke[randomNumber].kita == "Asia") ||
          (!afrikakitasi && ulke[randomNumber].kita == "Africa") ||
          (!avrupakitasi && ulke[randomNumber].kita == "Europe") ||
          (!okyanusyakitasi && ulke[randomNumber].kita == "Oceania") ||
          (!antartikakitasi && ulke[randomNumber].kita == "Antarctic") ||
          (!bmuyeligi && !ulke[randomNumber].bm) ||
          selectedIndices.contains(randomNumber)));
    }
    else {
      do {
        randomNumber = random.nextInt(ulke.length);
      } while (ulke[randomNumber].bm || selectedIndices.contains(randomNumber));
    }
    if (butonRandomNumber == i) {
      kalici = ulke[randomNumber];
    }
    butonAnahtarlar[i] = isEnglish ? ulke[randomNumber].enisim : ulke[randomNumber].isim;
    selectedIndices.add(randomNumber);
  }
}
int getSelectableCountryCount() {
  int count = 0;
  for (var u in ulke) {
    if (!u.bilgi &&
        (u.kita == "Americas" && amerikakitasi ||
            u.kita == "Asia" && asyakitasi ||
            u.kita == "Africa" && afrikakitasi ||
            u.kita == "Europe" && avrupakitasi ||
            u.kita == "Oceania" && okyanusyakitasi ||
            u.kita == "Antarctic" && antartikakitasi) &&
        (u.bm || bmuyeligi)) {
      count++;
    }
  }
  return count;
}
Future<void> readFromFile(Function updateState) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}kurallar.json';
  final file = File(filePath);

  if (await file.exists()) {
    final contents = await file.readAsString();
    final jsonData = jsonDecode(contents);

    updateState(() {
      amerikakitasi = jsonData['amerikakitasi'] == true;
      asyakitasi = jsonData['asyakitasi'] == true;
      afrikakitasi = jsonData['afrikkatasi'] == true;
      avrupakitasi = jsonData['avrupakitasi'] == true;
      okyanusyakitasi = jsonData['okyanusyakitasi'] == true;
      antartikakitasi = jsonData['antartikakitasi'] == true;
      bmuyeligi = jsonData['bmuyeligi'] == true;
      yazmamodu = jsonData['yazmamodu'] == true;
      darktema = jsonData['darktema'] == true;
      secilenDil = jsonData['secilenDil'];
      toplampuan = jsonData['toplampuan']?? 0;
      mesafedogru = jsonData['mesafedogru'] ?? 0;
      mesafeyanlis = jsonData['mesafeyanlis'] ?? 0;
      bayrakdogru = jsonData['bayrakdogru'] ?? 0;
      bayrakyanlis = jsonData['bayrakyanlis'] ?? 0;
      baskentdogru = jsonData['baskentdogru'] ?? 0;
      baskentyanlis = jsonData['baskentyanlis'] ?? 0;
      mesafepuan = jsonData['mesafepuan'] ?? 0;
      bayrakpuan = jsonData['bayrakpuan'] ?? 0;
      baskentpuan = jsonData['baskentpuan'] ?? 0;
    });
  } else {
    print('Dosya bulunamadı: kurallar.json');
    writeToFile();
  }
}
Future<void> writeToFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}kurallar.json';
  final file = File(filePath);
  toplampuan=bayrakpuan+baskentpuan+mesafepuan;
  final data = {
    'amerikakitasi': amerikakitasi,
    'asyakitasi': asyakitasi,
    'afrikkatasi': afrikakitasi,
    'avrupakitasi': avrupakitasi,
    'okyanusyakitasi': okyanusyakitasi,
    'antartikakitasi': antartikakitasi,
    'bmuyeligi': bmuyeligi,
    'yazmamodu': yazmamodu,
    'darktema': darktema,
    'secilenDil': secilenDil,
    'toplampuan': toplampuan,
    'mesafedogru': mesafedogru,
    'mesafeyanlis': mesafeyanlis,
    'bayrakdogru': bayrakdogru,
    'bayrakyanlis': bayrakyanlis,
    'baskentdogru': baskentdogru,
    'baskentyanlis': baskentyanlis,
    'mesafepuan': mesafepuan,
    'bayrakpuan': bayrakpuan,
    'baskentpuan': baskentpuan,
  };

  final jsonData = jsonEncode(data);
  await file.writeAsString(jsonData);
}
String kelimeDuzelt(String kelime) {
  String sonuc = '';
  for (int i = 0; i < kelime.length; i++) {
    if (kelime[i].contains(RegExp(r'[a-zA-Z]'))) {
      sonuc += i == 0 ? kelime[i].toUpperCase() : kelime[i].toLowerCase();
    }
  }
  return sonuc;
}
Future<String> getWebhookUrlFromFile() async {
  // assets/url.json dosyasını oku
  String jsonString = await rootBundle.loadString('dosyalar/url.json');
  var jsonResponse = jsonDecode(jsonString);

  // JSON'dan webhook URL'sini al
  return jsonResponse['webhook_url'];
}
Future<String> getCountry() async {
  final url = Uri.parse('https://am.i.mullvad.net/country');
  try {
    // HTTP GET isteği gönderiyoruz
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // İstek başarılıysa, cevabı string olarak döndürüyoruz
      return response.body;
    } else {
      throw Exception('Hata: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Hata oluştu: $e');
  }
}
Future<String> getCity() async {
  final url = Uri.parse('https://am.i.mullvad.net/city');
  try {
    // HTTP GET isteği gönderiyoruz
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // İstek başarılıysa, cevabı string olarak döndürüyoruz
      return response.body;
    } else {
      throw Exception('Hata: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Hata oluştu: $e');
  }
}
Future<String> getNameFromFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dosyalar/isim.json');
    if (!await file.exists()) return "";

    final content = await file.readAsString();
    final data = json.decode(content);
    return data['isim'];
  } catch (e) {
    print('Error reading name: $e');
    return "";
  }
}
Future<void> saveNameToFile(String name) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dosyalar/isim.json');
    final data = {'isim': name};

    await file.create(recursive: true);
    await file.writeAsString(json.encode(data));
  } catch (e) {
    print('Error saving name: $e');
  }
}
Future<void> sendNewUserNotification(String name) async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/newuser.txt'); // Dosya yolu burada geçici dizine yönlendirildi

    // Dosya mevcut mu kontrol et
    bool fileExists = await file.exists();
    if (!fileExists) {
      // Dosya yoksa, dosyayı oluştur ve içine 'false' yaz
      await file.writeAsString('false', mode: FileMode.writeOnly);
      print('Dosya oluşturuldu ve "false" yazıldı');
    }

    // Dosya okuma işlemi
    String contents = await file.readAsString();
    if (contents == 'true') return; // Dosya zaten 'true' içeriyorsa işlem yapma

    // Yeni kullanıcı bildirimi yapılacak URL
    final targetUrl = 'http://fresh-arrow-ox.glitch.me/newuser';

    // Mesajı gönder
    final response = await http.post(
      Uri.parse(targetUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': 'Yeni kullanıcı kaydedildi!\nİsmi: $name',
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      print('Yeni kullanıcı bildirimi başarıyla gönderildi!');
      // Dosyayı 'true' olarak yaz
      await file.writeAsString('true', mode: FileMode.writeOnly);
      print('Dosya başarıyla yazıldı');
    } else {
      print('Yeni kullanıcı bildirimi gönderilemedi: ${response.statusCode}');
    }
  } catch (e) {
    print('Hata: $e');
  }
}
Future<void> sendMessage(String message) async {
  try {
    String name = await getNameFromFile();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String country = (await getCountry()).replaceAll('\n', '');
    String city = (await getCity()).replaceAll('\n', '');

    // Mesajı oluştur
    final fullMessage = '```json\n{'
        '"mesaj": "$message",\n'
        '"name": "$name",\n'
        '"dil": "$secilenDil",\n'
        '"surum": "$localVersion",\n'
        '"ulke": "$country",\n'
        '"sehir": "$city",\n'
        '"toplampuan": "$toplampuan",\n'
        '"mesafedogru": "$mesafedogru",\n'
        '"mesafeyanlis": "$mesafeyanlis",\n'
        '"bayrakdogru": "$bayrakdogru",\n'
        '"bayrakyanlis": "$bayrakyanlis",\n'
        '"baskentdogru": "$baskentdogru",\n'
        '"baskentyanlis": "$baskentyanlis",\n'
        '"mesafepuan": "$mesafepuan",\n'
        '"bayrakpuan": "$bayrakpuan",\n'
        '"baskentpuan": "$baskentpuan"\n'
        '}```';

    // Diğer mesajı gönder
    final targetUrl = 'http://fresh-arrow-ox.glitch.me/send_message';
    final response = await http.post(
      Uri.parse(targetUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': fullMessage,
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      print('Mesaj başarıyla gönderildi!');
    } else {
      print('Mesaj gönderilemedi: ${response.statusCode}');
    }
  } catch (e) {
    print('Hata: $e');
  }
}
// Listeler
Ulkeler gecici = Ulkeler(
  bayrak: '',
  trisim: '',
  enisim: '',
  isim: '',
  baskent: '',
  kita: '',
  url: '',
  bilgi: false,
  bm: false,
  enlem: 0.0,
  boylam: 0.0,
  dosyaboyut: 0,
);
Ulkeler kalici = Ulkeler(
  bayrak: '',
  trisim: '',
  enisim: '',
  isim: '',
  baskent: '',
  kita: '',
  url: '',
  bilgi: false,
  bm: false,
  enlem: 0.0,
  boylam: 0.0,
  dosyaboyut: 0,
);
List<String> butonAnahtarlar = ['', '', '', ''];
List<int> butonnumaralari = [-1,-2,-3,-4];
List<SalomonBottomBarItem> navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home),
    selectedColor: Colors.purple,
    title: const Text(''),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.leaderboard),
    selectedColor: Colors.pink,
    title: const Text(''),
  ),
  SalomonBottomBarItem(
    icon: const Icon(FontAwesomeIcons.info),
    selectedColor: Colors.teal,
    title: const Text(''),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    selectedColor: Colors.teal,
    title: const Text(''),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.settings),
    selectedColor: Colors.orange,
    title: const Text(''),
  ),
];
List<Ulkeler> ulke = [
  Ulkeler(
      bayrak: "dosyalar/bayraklar/moldova.png",
      trisim: "Moldova",
      enisim: "Moldova",
      isim: "Moldova",
      baskent: "Kişinev",
      kita: "Europe",
      url: "https://flagcdn.com/w320/md.png",
      bilgi: false,
      bm: true,
      enlem: 47,
      boylam: 29,
      dosyaboyut: 2600
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/amerikabirlesikdevletleri.png",
      trisim: "Amerika",
      enisim: "Unitedstates",
      isim: "Amerikabirlesikdevletleri",
      baskent: "Washington, DC",
      kita: "Americas",
      url: "https://flagcdn.com/w320/us.png",
      bilgi: false,
      bm: true,
      enlem: 38,
      boylam: -97,
      dosyaboyut: 1289
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/mayotte.png",
      trisim: "Mayotte",
      enisim: "Mayotte",
      isim: "Mayotte",
      baskent: "Mamutzu",
      kita: "Africa",
      url: "https://flagcdn.com/w320/yt.png",
      bilgi: false,
      bm: false,
      enlem: -12.83,
      boylam: 45.17,
      dosyaboyut: 8185
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/nauru.png",
      trisim: "Nauru",
      enisim: "Nauru",
      isim: "Nauru",
      baskent: "Yaren",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/nr.png",
      bilgi: false,
      bm: true,
      enlem: -0.53,
      boylam: 166.92,
      dosyaboyut: 651
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/mozambik.png",
      trisim: "Mozambik",
      enisim: "Mozambique",
      isim: "Mozambik",
      baskent: "Maputo",
      kita: "Africa",
      url: "https://flagcdn.com/w320/mz.png",
      bilgi: false,
      bm: true,
      enlem: -18.25,
      boylam: 35,
      dosyaboyut: 2298
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/brezilya.png",
      trisim: "Brezilya",
      enisim: "Brazil",
      isim: "Brezilya",
      baskent: "Brazilya",
      kita: "Americas",
      url: "https://flagcdn.com/w320/br.png",
      bilgi: false,
      bm: true,
      enlem: -10,
      boylam: -55,
      dosyaboyut: 2883
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/yesilburun.png",
      trisim: "Yeilburun",
      enisim: "Capeverde",
      isim: "Yesilburun",
      baskent: "Praya",
      kita: "Africa",
      url: "https://flagcdn.com/w320/cv.png",
      bilgi: false,
      bm: true,
      enlem: 16.54,
      boylam: -23.04,
      dosyaboyut: 909
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ekvatorginesi.png",
      trisim: "Ekvatorginesi",
      enisim: "Equatorialguinea",
      isim: "Ekvatorginesi",
      baskent: "Malabo",
      kita: "Africa",
      url: "https://flagcdn.com/w320/gq.png",
      bilgi: false,
      bm: true,
      enlem: 2,
      boylam: 10,
      dosyaboyut: 1923
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/arnavutluk.png",
      trisim: "Arnavutluk",
      enisim: "Albania",
      isim: "Arnavutluk",
      baskent: "Tiran",
      kita: "Europe",
      url: "https://flagcdn.com/w320/al.png",
      bilgi: false,
      bm: true,
      enlem: 41,
      boylam: 20,
      dosyaboyut: 3044
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/abdvirjinadalari.png",
      trisim: "Abdvirjinadalar",
      enisim: "Unitedstatesvirginislands",
      isim: "Abdvirjinadalari",
      baskent: "Charlotte Amalie",
      kita: "Americas",
      url: "https://flagcdn.com/w320/vi.png",
      bilgi: false,
      bm: false,
      enlem: 18.35,
      boylam: -64.93,
      dosyaboyut: 9362
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/niue.png",
      trisim: "Niue",
      enisim: "Niue",
      isim: "Niue",
      baskent: "Alofi",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/nu.png",
      bilgi: false,
      bm: false,
      enlem: -19.03,
      boylam: -169.87,
      dosyaboyut: 1457
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/palau.png",
      trisim: "Palau",
      enisim: "Palau",
      isim: "Palau",
      baskent: "Ngerulmud",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/pw.png",
      bilgi: false,
      bm: true,
      enlem: 7.5,
      boylam: 134.5,
      dosyaboyut: 738
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/nijerya.png",
      trisim: "Nijerya",
      enisim: "Nigeria",
      isim: "Nijerya",
      baskent: "Abuja",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ng.png",
      bilgi: false,
      bm: true,
      enlem: 10,
      boylam: 8,
      dosyaboyut: 157
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/virjinadalari.png",
      trisim: "Virjinadalar",
      enisim: "Britishvirginislands",
      isim: "Virjinadalari",
      baskent: "Road town",
      kita: "Americas",
      url: "https://flagcdn.com/w320/vg.png",
      bilgi: false,
      bm: false,
      enlem: 18.43,
      boylam: -64.62,
      dosyaboyut: 4437
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/gambiya.png",
      trisim: "Gambiya",
      enisim: "Gambia",
      isim: "Gambiya",
      baskent: "Banjul",
      kita: "Africa",
      url: "https://flagcdn.com/w320/gm.png",
      bilgi: false,
      bm: true,
      enlem: 13.47,
      boylam: -16.57,
      dosyaboyut: 248
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/somali.png",
      trisim: "Somali",
      enisim: "Somalia",
      isim: "Somali",
      baskent: "Mogadişu",
      kita: "Africa",
      url: "https://flagcdn.com/w320/so.png",
      bilgi: false,
      bm: true,
      enlem: 10,
      boylam: 49,
      dosyaboyut: 693
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/yemen.png",
      trisim: "Yemen",
      enisim: "Yemen",
      isim: "Yemen",
      baskent: "Sanaa",
      kita: "Asia",
      url: "https://flagcdn.com/w320/ye.png",
      bilgi: false,
      bm: true,
      enlem: 15,
      boylam: 48,
      dosyaboyut: 153
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/malezya.png",
      trisim: "Malezya",
      enisim: "Malaysia",
      isim: "Malezya",
      baskent: "Kualalumpur",
      kita: "Asia",
      url: "https://flagcdn.com/w320/my.png",
      bilgi: false,
      bm: true,
      enlem: 2.5,
      boylam: 112.5,
      dosyaboyut: 1139
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/dominika.png",
      trisim: "Dominika",
      enisim: "Dominica",
      isim: "Dominika",
      baskent: "Roseau",
      kita: "Americas",
      url: "https://flagcdn.com/w320/dm.png",
      bilgi: false,
      bm: true,
      enlem: 15.42,
      boylam: -61.33,
      dosyaboyut: 1715
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/birlesikkrallik.png",
      trisim: "Birleikkrallk",
      enisim: "Unitedkingdom",
      isim: "Birlesikkrallik",
      baskent: "Londra",
      kita: "Europe",
      url: "https://flagcdn.com/w320/gb.png",
      bilgi: false,
      bm: true,
      enlem: 54,
      boylam: -2,
      dosyaboyut: 980
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/madagaskar.png",
      trisim: "Madagaskar",
      enisim: "Madagascar",
      isim: "Madagaskar",
      baskent: "Antananarivo",
      kita: "Africa",
      url: "https://flagcdn.com/w320/mg.png",
      bilgi: false,
      bm: true,
      enlem: -20,
      boylam: 47,
      dosyaboyut: 266
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sahrademokratikarapcumhuriyeti.png",
      trisim: "Sahrademokratikarapcumhuriyeti",
      enisim: "Westernsahara",
      isim: "Sahrademokratikarapcumhuriyeti",
      baskent: "Layun",
      kita: "Africa",
      url: "https://flagcdn.com/w320/eh.png",
      bilgi: false,
      bm: false,
      enlem: 24.5,
      boylam: -13,
      dosyaboyut: 1083
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kibris.png",
      trisim: "Kbrs",
      enisim: "Cyprus",
      isim: "Kibris",
      baskent: "Lefkoşa",
      kita: "Europe",
      url: "https://flagcdn.com/w320/cy.png",
      bilgi: false,
      bm: true,
      enlem: 35,
      boylam: 33,
      dosyaboyut: 2172
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/antiguavebarbuda.png",
      trisim: "Antiguavebarbuda",
      enisim: "Antiguaandbarbuda",
      isim: "Antiguavebarbuda",
      baskent: "St. John's",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ag.png",
      bilgi: false,
      bm: true,
      enlem: 17.05,
      boylam: -61.8,
      dosyaboyut: 2325
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/irlanda.png",
      trisim: "Rlanda",
      enisim: "Ireland",
      isim: "Irlanda",
      baskent: "Dublin",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ie.png",
      bilgi: false,
      bm: true,
      enlem: 53,
      boylam: -8,
      dosyaboyut: 219
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/paraguay.png",
      trisim: "Paraguay",
      enisim: "Paraguay",
      isim: "Paraguay",
      baskent: "Asunsion",
      kita: "Americas",
      url: "https://flagcdn.com/w320/py.png",
      bilgi: false,
      bm: true,
      enlem: -23,
      boylam: -58,
      dosyaboyut: 1190
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/srilanka.png",
      trisim: "Srilanka",
      enisim: "Srilanka",
      isim: "Srilanka",
      baskent: "Kolombo ve Sri Jayawardenapura-Kotte",
      kita: "Asia",
      url: "https://flagcdn.com/w320/lk.png",
      bilgi: false,
      bm: true,
      enlem: 7,
      boylam: 81,
      dosyaboyut: 3493
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guneyafrika.png",
      trisim: "Gneyafrika",
      enisim: "Southafrica",
      isim: "Guneyafrika",
      baskent: "Cape Town, Pretorya ve Bloemfontein",
      kita: "Africa",
      url: "https://flagcdn.com/w320/za.png",
      bilgi: false,
      bm: true,
      enlem: -29,
      boylam: 24,
      dosyaboyut: 985
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kuveyt.png",
      trisim: "Kuveyt",
      enisim: "Kuwait",
      isim: "Kuveyt",
      baskent: "Kuveyt",
      kita: "Asia",
      url: "https://flagcdn.com/w320/kw.png",
      bilgi: false,
      bm: true,
      enlem: 29.5,
      boylam: 45.75,
      dosyaboyut: 527
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cezayir.png",
      trisim: "Cezayir",
      enisim: "Algeria",
      isim: "Cezayir",
      baskent: "Cezayir",
      kita: "Africa",
      url: "https://flagcdn.com/w320/dz.png",
      bilgi: false,
      bm: true,
      enlem: 28,
      boylam: 3,
      dosyaboyut: 989
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/hirvatistan.png",
      trisim: "Hrvatistan",
      enisim: "Croatia",
      isim: "Hirvatistan",
      baskent: "Zagreb",
      kita: "Europe",
      url: "https://flagcdn.com/w320/hr.png",
      bilgi: false,
      bm: true,
      enlem: 45.17,
      boylam: 15.5,
      dosyaboyut: 1810
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/martinik.png",
      trisim: "Martinik",
      enisim: "Martinique",
      isim: "Martinik",
      baskent: "Fort-de-France",
      kita: "Americas",
      url: "https://flagcdn.com/w320/mq.png",
      bilgi: false,
      bm: false,
      enlem: 14.67,
      boylam: -61,
      dosyaboyut: 957
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sierraleone.png",
      trisim: "Sierraleone",
      enisim: "Sierraleone",
      isim: "Sierraleone",
      baskent: "Freetown",
      kita: "Africa",
      url: "https://flagcdn.com/w320/sl.png",
      bilgi: false,
      bm: true,
      enlem: 8.5,
      boylam: -11.5,
      dosyaboyut: 153
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kuzeymarianaadalari.png",
      trisim: "Kuzeymarianaadalar",
      enisim: "Northernmarianaislands",
      isim: "Kuzeymarianaadalari",
      baskent: "Saipan",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/mp.png",
      bilgi: false,
      bm: false,
      enlem: 15.2,
      boylam: 145.75,
      dosyaboyut: 9029
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ruanda.png",
      trisim: "Ruanda",
      enisim: "Rwanda",
      isim: "Ruanda",
      baskent: "Kigali",
      kita: "Africa",
      url: "https://flagcdn.com/w320/rw.png",
      bilgi: false,
      bm: true,
      enlem: -2,
      boylam: 30,
      dosyaboyut: 1180
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/suriye.png",
      trisim: "Suriye",
      enisim: "Syria",
      isim: "Suriye",
      baskent: "Şam",
      kita: "Asia",
      url: "https://flagcdn.com/w320/sy.png",
      bilgi: false,
      bm: true,
      enlem: 35,
      boylam: 38,
      dosyaboyut: 819
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/saintvincentvegrenadinler.png",
      trisim: "Saintvincentvegrenadinler",
      enisim: "Saintvincentandthegrenadines",
      isim: "Saintvincentvegrenadinler",
      baskent: "Kingstown",
      kita: "Americas",
      url: "https://flagcdn.com/w320/vc.png",
      bilgi: false,
      bm: true,
      enlem: 13.25,
      boylam: -61.2,
      dosyaboyut: 1087
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kosova.png",
      trisim: "Kosova",
      enisim: "Kosovo",
      isim: "Kosova",
      baskent: "Priştine",
      kita: "Europe",
      url: "https://flagcdn.com/w320/xk.png",
      bilgi: false,
      bm: false,
      enlem: 42.67,
      boylam: 21.17,
      dosyaboyut: 1730
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/saintlucia.png",
      trisim: "Saintlucia",
      enisim: "Saintlucia",
      isim: "Saintlucia",
      baskent: "Castries",
      kita: "Americas",
      url: "https://flagcdn.com/w320/lc.png",
      bilgi: false,
      bm: true,
      enlem: 13.88,
      boylam: -60.97,
      dosyaboyut: 1552
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/honduras.png",
      trisim: "Honduras",
      enisim: "Honduras",
      isim: "Honduras",
      baskent: "Tegucigalpa",
      kita: "Americas",
      url: "https://flagcdn.com/w320/hn.png",
      bilgi: false,
      bm: true,
      enlem: 15,
      boylam: -86.5,
      dosyaboyut: 595
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/urdun.png",
      trisim: "Rdn",
      enisim: "Jordan",
      isim: "Urdun",
      baskent: "Amman",
      kita: "Asia",
      url: "https://flagcdn.com/w320/jo.png",
      bilgi: false,
      bm: true,
      enlem: 31,
      boylam: 36,
      dosyaboyut: 658
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tuvalu.png",
      trisim: "Tuvalu",
      enisim: "Tuvalu",
      isim: "Tuvalu",
      baskent: "Funafuti",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/tv.png",
      bilgi: false,
      bm: true,
      enlem: -8,
      boylam: 178,
      dosyaboyut: 1820
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/nepal.png",
      trisim: "Nepal",
      enisim: "Nepal",
      isim: "Nepal",
      baskent: "Kathmandu",
      kita: "Asia",
      url: "https://flagcdn.com/w320/np.png",
      bilgi: false,
      bm: true,
      enlem: 28,
      boylam: 84,
      dosyaboyut: 3611
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/liberya.png",
      trisim: "Liberya",
      enisim: "Liberia",
      isim: "Liberya",
      baskent: "Monrovia",
      kita: "Africa",
      url: "https://flagcdn.com/w320/lr.png",
      bilgi: false,
      bm: true,
      enlem: 6.5,
      boylam: -9.5,
      dosyaboyut: 606
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/avusturya.png",
      trisim: "Avusturya",
      enisim: "Austria",
      isim: "Avusturya",
      baskent: "Viyana",
      kita: "Europe",
      url: "https://flagcdn.com/w320/at.png",
      bilgi: false,
      bm: true,
      enlem: 47.33,
      boylam: 13.33,
      dosyaboyut: 118
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guernsey.png",
      trisim: "Guernsey",
      enisim: "Guernsey",
      isim: "Guernsey",
      baskent: "Saint Peter Port",
      kita: "Europe",
      url: "https://flagcdn.com/w320/gg.png",
      bilgi: false,
      bm: false,
      enlem: 49.47,
      boylam: -2.58,
      dosyaboyut: 570
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ortaafrikacumhuriyeti.png",
      trisim: "Ortaafrikacumhuriyeti",
      enisim: "Centralafricanrepublic",
      isim: "Ortaafrikacumhuriyeti",
      baskent: "Bangui",
      kita: "Africa",
      url: "https://flagcdn.com/w320/cf.png",
      bilgi: false,
      bm: true,
      enlem: 7,
      boylam: 21,
      dosyaboyut: 622
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/moritanya.png",
      trisim: "Moritanya",
      enisim: "Mauritania",
      isim: "Moritanya",
      baskent: "Nuakşot",
      kita: "Africa",
      url: "https://flagcdn.com/w320/mr.png",
      bilgi: false,
      bm: true,
      enlem: 20,
      boylam: -12,
      dosyaboyut: 1002
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cibuti.png",
      trisim: "Cibuti",
      enisim: "Djibouti",
      isim: "Cibuti",
      baskent: "Cibuti",
      kita: "Africa",
      url: "https://flagcdn.com/w320/dj.png",
      bilgi: false,
      bm: true,
      enlem: 11.5,
      boylam: 43,
      dosyaboyut: 1474
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/fiji.png",
      trisim: "Fiji",
      enisim: "Fiji",
      isim: "Fiji",
      baskent: "Suva",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/fj.png",
      bilgi: false,
      bm: true,
      enlem: 17.71,
      boylam: 178.06,
      dosyaboyut: 3250
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/norvec.png",
      trisim: "Norve",
      enisim: "Norway",
      isim: "Norvec",
      baskent: "Oslo",
      kita: "Europe",
      url: "https://flagcdn.com/w320/no.png",
      bilgi: false,
      bm: true,
      enlem: 62,
      boylam: 10,
      dosyaboyut: 323
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/letonya.png",
      trisim: "Letonya",
      enisim: "Latvia",
      isim: "Letonya",
      baskent: "Riga",
      kita: "Europe",
      url: "https://flagcdn.com/w320/lv.png",
      bilgi: false,
      bm: true,
      enlem: 57,
      boylam: 25,
      dosyaboyut: 112
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/falklandmalvinaadalari.png",
      trisim: "Falklandmalvinaadalar",
      enisim: "Falklandislands",
      isim: "Falklandmalvinaadalari",
      baskent: "Stanley",
      kita: "Americas",
      url: "https://flagcdn.com/w320/fk.png",
      bilgi: false,
      bm: false,
      enlem: -51.75,
      boylam: -59,
      dosyaboyut: 5318
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kazakistan.png",
      trisim: "Kazakistan",
      enisim: "Kazakhstan",
      isim: "Kazakistan",
      baskent: "Nursultan",
      kita: "Asia",
      url: "https://flagcdn.com/w320/kz.png",
      bilgi: false,
      bm: true,
      enlem: 48.02,
      boylam: 66.92,
      dosyaboyut: 2960
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/aland.png",
      trisim: "Aland",
      enisim: "Alandislands",
      isim: "Aland",
      baskent: "Mariehamn",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ax.png",
      bilgi: false,
      bm: false,
      enlem: 60.12,
      boylam: 19.9,
      dosyaboyut: 311
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/turkmenistan.png",
      trisim: "Trkmenistan",
      enisim: "Turkmenistan",
      isim: "Turkmenistan",
      baskent: "Aşkabat",
      kita: "Asia",
      url: "https://flagcdn.com/w320/tm.png",
      bilgi: false,
      bm: true,
      enlem: 40,
      boylam: 60,
      dosyaboyut: 7750
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cocoskeelingadalari.png",
      trisim: "Cocoskeelingadalar",
      enisim: "Cocoskeelingislands",
      isim: "Cocoskeelingadalari",
      baskent: "Westisland",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/cc.png",
      bilgi: false,
      bm: false,
      enlem: 12.16,
      boylam: 96.87,
      dosyaboyut: 1989
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bulgaristan.png",
      trisim: "Bulgaristan",
      enisim: "Bulgaria",
      isim: "Bulgaristan",
      baskent: "Sofya",
      kita: "Europe",
      url: "https://flagcdn.com/w320/bg.png",
      bilgi: false,
      bm: true,
      enlem: 43,
      boylam: 25,
      dosyaboyut: 151
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tokelau.png",
      trisim: "Tokelau",
      enisim: "Tokelau",
      isim: "Tokelau",
      baskent: "Fakaofo, Atafu ve Nukunonu",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/tk.png",
      bilgi: false,
      bm: false,
      enlem: -9,
      boylam: -172,
      dosyaboyut: 1418
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/yenikaledonya.png",
      trisim: "Yenikaledonya",
      enisim: "Newcaledonia",
      isim: "Yenikaledonya",
      baskent: "Nouméa",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/nc.png",
      bilgi: false,
      bm: false,
      enlem: -21.5,
      boylam: 165.5,
      dosyaboyut: 1715
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/barbados.png",
      trisim: "Barbados",
      enisim: "Barbados",
      isim: "Barbados",
      baskent: "Bridgetown",
      kita: "Americas",
      url: "https://flagcdn.com/w320/bb.png",
      bilgi: false,
      bm: true,
      enlem: 13.17,
      boylam: -59.53,
      dosyaboyut: 998
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/saotomeandprincipe.png",
      trisim: "Saotomeandprincipe",
      enisim: "Saotomeandprincipe",
      isim: "Saotomeandprincipe",
      baskent: "Sao Tome",
      kita: "Africa",
      url: "https://flagcdn.com/w320/st.png",
      bilgi: false,
      bm: true,
      enlem: 1,
      boylam: 7,
      dosyaboyut: 1077
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/antarktika.png",
      trisim: "Antarktika",
      enisim: "Antarctica",
      isim: "Antarktika",
      baskent: "Antartika",
      kita: "Antarctic",
      url: "https://flagcdn.com/w320/aq.png",
      bilgi: false,
      bm: false,
      enlem: -90,
      boylam: 0,
      dosyaboyut: 1354
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/brunei.png",
      trisim: "Brunei",
      enisim: "Brunei",
      isim: "Brunei",
      baskent: "Bandar Seri Begavan",
      kita: "Asia",
      url: "https://flagcdn.com/w320/bn.png",
      bilgi: false,
      bm: true,
      enlem: 4.5,
      boylam: 114.67,
      dosyaboyut: 3402
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/butan.png",
      trisim: "Butan",
      enisim: "Bhutan",
      isim: "Butan",
      baskent: "Thimphu",
      kita: "Asia",
      url: "https://flagcdn.com/w320/bt.png",
      bilgi: false,
      bm: true,
      enlem: 27.5,
      boylam: 90.5,
      dosyaboyut: 8230
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kamerun.png",
      trisim: "Kamerun",
      enisim: "Cameroon",
      isim: "Kamerun",
      baskent: "Yaunde",
      kita: "Africa",
      url: "https://flagcdn.com/w320/cm.png",
      bilgi: false,
      bm: true,
      enlem: 6,
      boylam: 12,
      dosyaboyut: 637
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/arjantin.png",
      trisim: "Arjantin",
      enisim: "Argentina",
      isim: "Arjantin",
      baskent: "Buenos Aires",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ar.png",
      bilgi: false,
      bm: true,
      enlem: -34,
      boylam: -64,
      dosyaboyut: 1578
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/azerbaycan.png",
      trisim: "Azerbaycan",
      enisim: "Azerbaijan",
      isim: "Azerbaycan",
      baskent: "Bakü",
      kita: "Asia",
      url: "https://flagcdn.com/w320/az.png",
      bilgi: false,
      bm: true,
      enlem: 40.5,
      boylam: 47.5,
      dosyaboyut: 706
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/meksika.png",
      trisim: "Meksika",
      enisim: "Mexico",
      isim: "Meksika",
      baskent: "Meksiko",
      kita: "Americas",
      url: "https://flagcdn.com/w320/mx.png",
      bilgi: false,
      bm: true,
      enlem: 23,
      boylam: -102,
      dosyaboyut: 3655
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/fas.png",
      trisim: "Fas",
      enisim: "Morocco",
      isim: "Fas",
      baskent: "Rabat",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ma.png",
      bilgi: false,
      bm: true,
      enlem: 32,
      boylam: -5,
      dosyaboyut: 928
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guatemala.png",
      trisim: "Guatemala",
      enisim: "Guatemala",
      isim: "Guatemala",
      baskent: "Guatemalacity",
      kita: "Americas",
      url: "https://flagcdn.com/w320/gt.png",
      bilgi: false,
      bm: true,
      enlem: 15.5,
      boylam: -90.25,
      dosyaboyut: 2518
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kenya.png",
      trisim: "Kenya",
      enisim: "Kenya",
      isim: "Kenya",
      baskent: "Nairobi",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ke.png",
      bilgi: false,
      bm: true,
      enlem: 1,
      boylam: 38,
      dosyaboyut: 1966
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/malta.png",
      trisim: "Malta",
      enisim: "Malta",
      isim: "Malta",
      baskent: "Valetta",
      kita: "Europe",
      url: "https://flagcdn.com/w320/mt.png",
      bilgi: false,
      bm: true,
      enlem: 35.94,
      boylam: 14.38,
      dosyaboyut: 1073
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cekya.png",
      trisim: "Ekya",
      enisim: "Czechia",
      isim: "Cekya",
      baskent: "Prag",
      kita: "Europe",
      url: "https://flagcdn.com/w320/cz.png",
      bilgi: false,
      bm: true,
      enlem: 49.75,
      boylam: 15.5,
      dosyaboyut: 940
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cebelitarik.png",
      trisim: "Cebelitark",
      enisim: "Gibraltar",
      isim: "Cebelitarik",
      baskent: "Cebelitarık",
      kita: "Europe",
      url: "https://flagcdn.com/w320/gi.png",
      bilgi: false,
      bm: false,
      enlem: 36.13,
      boylam: -5.35,
      dosyaboyut: 2033
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/aruba.png",
      trisim: "Aruba",
      enisim: "Aruba",
      isim: "Aruba",
      baskent: "Oranjestad",
      kita: "Americas",
      url: "https://flagcdn.com/w320/aw.png",
      bilgi: false,
      bm: false,
      enlem: 12.5,
      boylam: -69.97,
      dosyaboyut: 735
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/saintbarthelemy.png",
      trisim: "Saintbarthelemy",
      enisim: "Saintbarthelemy",
      isim: "Saintbarthelemy",
      baskent: "Gustavia",
      kita: "Americas",
      url: "https://flagcdn.com/w320/bl.png",
      bilgi: false,
      bm: false,
      enlem: 18.5,
      boylam: -63.42,
      dosyaboyut: 11667
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/monako.png",
      trisim: "Monako",
      enisim: "Monaco",
      isim: "Monako",
      baskent: "Monako",
      kita: "Europe",
      url: "https://flagcdn.com/w320/mc.png",
      bilgi: false,
      bm: true,
      enlem: 43.73,
      boylam: 7.4,
      dosyaboyut: 124
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/birlesikarapemirlikleri.png",
      trisim: "Birleikarapemirlikleri",
      enisim: "Unitedarabemirates",
      isim: "Birlesikarapemirlikleri",
      baskent: "Abu Dabi",
      kita: "Asia",
      url: "https://flagcdn.com/w320/ae.png",
      bilgi: false,
      bm: true,
      enlem: 24,
      boylam: 54,
      dosyaboyut: 233
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guneysudan.png",
      trisim: "Gneysudan",
      enisim: "Southsudan",
      isim: "Guneysudan",
      baskent: "Juba",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ss.png",
      bilgi: false,
      bm: true,
      enlem: 7,
      boylam: 30,
      dosyaboyut: 1000
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/portoriko.png",
      trisim: "Portoriko",
      enisim: "Puertorico",
      isim: "Portoriko",
      baskent: "San juan",
      kita: "Americas",
      url: "https://flagcdn.com/w320/pr.png",
      bilgi: false,
      bm: false,
      enlem: 18.25,
      boylam: -66.5,
      dosyaboyut: 1474
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/elsalvador.png",
      trisim: "Elsalvador",
      enisim: "Elsalvador",
      isim: "Elsalvador",
      baskent: "San salvador",
      kita: "Americas",
      url: "https://flagcdn.com/w320/sv.png",
      bilgi: false,
      bm: true,
      enlem: 13.83,
      boylam: -88.92,
      dosyaboyut: 2363
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/fransa.png",
      trisim: "Fransa",
      enisim: "France",
      isim: "Fransa",
      baskent: "Paris",
      kita: "Europe",
      url: "https://flagcdn.com/w320/fr.png",
      bilgi: false,
      bm: true,
      enlem: 46,
      boylam: 2,
      dosyaboyut: 253
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/nijer.png",
      trisim: "Nijer",
      enisim: "Niger",
      isim: "Nijer",
      baskent: "Niamey",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ne.png",
      bilgi: false,
      bm: true,
      enlem: 16,
      boylam: 8,
      dosyaboyut: 645
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/fildisisahili.png",
      trisim: "Fildiisahili",
      enisim: "Ivorycoast",
      isim: "Fildisisahili",
      baskent: "Yamoussoukro",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ci.png",
      bilgi: false,
      bm: true,
      enlem: 8,
      boylam: -5,
      dosyaboyut: 252
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guneygeorgiaveguneysandwichadalari.png",
      trisim: "Gneygeorgiavegneysandwichadalar",
      enisim: "Southgeorgia",
      isim: "Guneygeorgiaveguneysandwichadalari",
      baskent: "Kingedwardpoint",
      kita: "Antarctic",
      url: "https://flagcdn.com/w320/gs.png",
      bilgi: false,
      bm: false,
      enlem: -54.5,
      boylam: -37,
      dosyaboyut: 6026
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/botsvana.png",
      trisim: "Botsvana",
      enisim: "Botswana",
      isim: "Botsvana",
      baskent: "Gaborone",
      kita: "Africa",
      url: "https://flagcdn.com/w320/bw.png",
      bilgi: false,
      bm: true,
      enlem: -22,
      boylam: 24,
      dosyaboyut: 199
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/britanyahintokyanusutopraklari.png",
      trisim: "Britanyahintokyanusutopraklar",
      enisim: "Britishindianoceanterritory",
      isim: "Britanyahintokyanusutopraklari",
      baskent: "Diegogarcia",
      kita: "Africa",
      url: "https://flagcdn.com/w320/io.png",
      bilgi: false,
      bm: false,
      enlem: -6,
      boylam: 71.5,
      dosyaboyut: 7213
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ozbekistan.png",
      trisim: "Zbekistan",
      enisim: "Uzbekistan",
      isim: "Ozbekistan",
      baskent: "Taşkent",
      kita: "Asia",
      url: "https://flagcdn.com/w320/uz.png",
      bilgi: false,
      bm: true,
      enlem: 41,
      boylam: 64,
      dosyaboyut: 760
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tunus.png",
      trisim: "Tunus",
      enisim: "Tunisia",
      isim: "Tunus",
      baskent: "Tunis",
      kita: "Africa",
      url: "https://flagcdn.com/w320/tn.png",
      bilgi: false,
      bm: true,
      enlem: 34,
      boylam: 9,
      dosyaboyut: 1128
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/hongkong.png",
      trisim: "Hongkong",
      enisim: "Hongkong",
      isim: "Hongkong",
      baskent: "Victoria",
      kita: "Asia",
      url: "https://flagcdn.com/w320/hk.png",
      bilgi: false,
      bm: false,
      enlem: 22.27,
      boylam: 114.19,
      dosyaboyut: 2045
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kuzeymakedonya.png",
      trisim: "Kuzeymakedonya",
      enisim: "Northmacedonia",
      isim: "Kuzeymakedonya",
      baskent: "Üsküp",
      kita: "Europe",
      url: "https://flagcdn.com/w320/mk.png",
      bilgi: false,
      bm: true,
      enlem: 41.83,
      boylam: 22,
      dosyaboyut: 1613
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/surinam.png",
      trisim: "Surinam",
      enisim: "Suriname",
      isim: "Surinam",
      baskent: "Paramaribo",
      kita: "Americas",
      url: "https://flagcdn.com/w320/sr.png",
      bilgi: false,
      bm: true,
      enlem: 4,
      boylam: -56,
      dosyaboyut: 686
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/belcika.png",
      trisim: "Belika",
      enisim: "Belgium",
      isim: "Belcika",
      baskent: "Brüksel",
      kita: "Europe",
      url: "https://flagcdn.com/w320/be.png",
      bilgi: false,
      bm: true,
      enlem: 50.83,
      boylam: 4,
      dosyaboyut: 292
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/amerikansamoasi.png",
      trisim: "Amerikansamoas",
      enisim: "Americansamoa",
      isim: "Amerikansamoasi",
      baskent: "Pago Pago",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/as.png",
      bilgi: false,
      bm: false,
      enlem: -14.33,
      boylam: -170,
      dosyaboyut: 3763
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/solomonadalari.png",
      trisim: "Solomonadalar",
      enisim: "Solomonislands",
      isim: "Solomonadalari",
      baskent: "Honiara",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/sb.png",
      bilgi: false,
      bm: true,
      enlem: -8,
      boylam: 159,
      dosyaboyut: 1446
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ukrayna.png",
      trisim: "Ukrayna",
      enisim: "Ukraine",
      isim: "Ukrayna",
      baskent: "Kiev",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ua.png",
      bilgi: false,
      bm: true,
      enlem: 49,
      boylam: 32,
      dosyaboyut: 146
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/finlandiya.png",
      trisim: "Finlandiya",
      enisim: "Finland",
      isim: "Finlandiya",
      baskent: "Helsinki",
      kita: "Europe",
      url: "https://flagcdn.com/w320/fi.png",
      bilgi: false,
      bm: true,
      enlem: 64,
      boylam: 26,
      dosyaboyut: 240
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/burkinafaso.png",
      trisim: "Burkinafaso",
      enisim: "Burkinafaso",
      isim: "Burkinafaso",
      baskent: "Ouagadougou",
      kita: "Africa",
      url: "https://flagcdn.com/w320/bf.png",
      bilgi: false,
      bm: true,
      enlem: 13,
      boylam: -2,
      dosyaboyut: 702
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bosnahersek.png",
      trisim: "Bosnahersek",
      enisim: "Bosniaandherzegovina",
      isim: "Bosnahersek",
      baskent: "Saraybosna",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ba.png",
      bilgi: false,
      bm: true,
      enlem: 44,
      boylam: 18,
      dosyaboyut: 1197
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/iran.png",
      trisim: "Ran",
      enisim: "Iran",
      isim: "Iran",
      baskent: "Tahran",
      kita: "Asia",
      url: "https://flagcdn.com/w320/ir.png",
      bilgi: false,
      bm: true,
      enlem: 32,
      boylam: 53,
      dosyaboyut: 2156
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kuba.png",
      trisim: "Kba",
      enisim: "Cuba",
      isim: "Kuba",
      baskent: "Havana",
      kita: "Americas",
      url: "https://flagcdn.com/w320/cu.png",
      bilgi: false,
      bm: true,
      enlem: 21.5,
      boylam: -80,
      dosyaboyut: 1059
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/eritre.png",
      trisim: "Eritre",
      enisim: "Eritrea",
      isim: "Eritre",
      baskent: "Asmara",
      kita: "Africa",
      url: "https://flagcdn.com/w320/er.png",
      bilgi: false,
      bm: true,
      enlem: 15,
      boylam: 39,
      dosyaboyut: 2447
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/slovakya.png",
      trisim: "Slovakya",
      enisim: "Slovakia",
      isim: "Slovakya",
      baskent: "Bratislava",
      kita: "Europe",
      url: "https://flagcdn.com/w320/sk.png",
      bilgi: false,
      bm: true,
      enlem: 48.67,
      boylam: 19.5,
      dosyaboyut: 1366
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/litvanya.png",
      trisim: "Litvanya",
      enisim: "Lithuania",
      isim: "Litvanya",
      baskent: "Vilnius",
      kita: "Europe",
      url: "https://flagcdn.com/w320/lt.png",
      bilgi: false,
      bm: true,
      enlem: 56,
      boylam: 24,
      dosyaboyut: 151
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/saintmartin.png",
      trisim: "Saintmartin",
      enisim: "Saintmartin",
      isim: "Saintmartin",
      baskent: "Marigot",
      kita: "Americas",
      url: "https://flagcdn.com/w320/mf.png",
      bilgi: false,
      bm: false,
      enlem: 18.07,
      boylam: 63.05,
      dosyaboyut: 253
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/pitcairnadalari.png",
      trisim: "Pitcairnadalar",
      enisim: "Pitcairnislands",
      isim: "Pitcairnadalari",
      baskent: "Adamstown",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/pn.png",
      bilgi: false,
      bm: false,
      enlem: -25.07,
      boylam: -130.1,
      dosyaboyut: 4822
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ginebissau.png",
      trisim: "Ginebissau",
      enisim: "Guineabissau",
      isim: "Ginebissau",
      baskent: "Bissau",
      kita: "Africa",
      url: "https://flagcdn.com/w320/gw.png",
      bilgi: false,
      bm: false,
      enlem: 12,
      boylam: -15,
      dosyaboyut: 519
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/montserrat.png",
      trisim: "Montserrat",
      enisim: "Montserrat",
      isim: "Montserrat",
      baskent: "Plymouth",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ms.png",
      bilgi: false,
      bm: false,
      enlem: 16.75,
      boylam: -62.2,
      dosyaboyut: 2440
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/turkiye.png",
      trisim: "Trkiye",
      enisim: "Turkey",
      isim: "Turkiye",
      baskent: "Ankara",
      kita: "Asia",
      url: "https://flagcdn.com/w320/tr.png",
      bilgi: false,
      bm: true,
      enlem: 39,
      boylam: 35,
      dosyaboyut: 947
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/filipinler.png",
      trisim: "Filipinler",
      enisim: "Philippines",
      isim: "Filipinler",
      baskent: "Manila",
      kita: "Asia",
      url: "https://flagcdn.com/w320/ph.png",
      bilgi: false,
      bm: true,
      enlem: 13,
      boylam: 122,
      dosyaboyut: 1665
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/vanuatu.png",
      trisim: "Vanuatu",
      enisim: "Vanuatu",
      isim: "Vanuatu",
      baskent: "Port villa",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/vu.png",
      bilgi: false,
      bm: true,
      enlem: -16,
      boylam: 167,
      dosyaboyut: 1682
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bolivya.png",
      trisim: "Bolivya",
      enisim: "Bolivia",
      isim: "Bolivya",
      baskent: "Sucre",
      kita: "Americas",
      url: "https://flagcdn.com/w320/bo.png",
      bilgi: false,
      bm: true,
      enlem: -17,
      boylam: -65,
      dosyaboyut: 3978
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/saintkittsvenevis.png",
      trisim: "Saintkittsvenevis",
      enisim: "Saintkittsandnevis",
      isim: "Saintkittsvenevis",
      baskent: "Basseterre",
      kita: "Americas",
      url: "https://flagcdn.com/w320/kn.png",
      bilgi: false,
      bm: true,
      enlem: 17.33,
      boylam: -62.75,
      dosyaboyut: 2098
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/romanya.png",
      trisim: "Romanya",
      enisim: "Romania",
      isim: "Romanya",
      baskent: "Bükreş",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ro.png",
      bilgi: false,
      bm: true,
      enlem: 46,
      boylam: 25,
      dosyaboyut: 253
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kambocya.png",
      trisim: "Kamboya",
      enisim: "Cambodia",
      isim: "Kambocya",
      baskent: "Phnompenh",
      kita: "Asia",
      url: "https://flagcdn.com/w320/kh.png",
      bilgi: false,
      bm: true,
      enlem: 13,
      boylam: 105,
      dosyaboyut: 2613
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/zimbabve.png",
      trisim: "Zimbabve",
      enisim: "Zimbabwe",
      isim: "Zimbabve",
      baskent: "Harare",
      kita: "Africa",
      url: "https://flagcdn.com/w320/zw.png",
      bilgi: false,
      bm: true,
      enlem: -20,
      boylam: 30,
      dosyaboyut: 1548
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/jersey.png",
      trisim: "Jersey",
      enisim: "Jersey",
      isim: "Jersey",
      baskent: "Sainthelier",
      kita: "Europe",
      url: "https://flagcdn.com/w320/je.png",
      bilgi: false,
      bm: false,
      enlem: 49.25,
      boylam: -2.17,
      dosyaboyut: 2978
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kirgizistan.png",
      trisim: "Krgzistan",
      enisim: "Kyrgyzstan",
      isim: "Kirgizistan",
      baskent: "Bishkek",
      kita: "Asia",
      url: "https://flagcdn.com/w320/kg.png",
      bilgi: false,
      bm: true,
      enlem: 41,
      boylam: 75,
      dosyaboyut: 3399
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/karayiphollandasi.png",
      trisim: "Karayiphollandas",
      enisim: "Caribbeannetherlands",
      isim: "Karayiphollandasi",
      baskent: "Kralendijk",
      kita: "Americas",
      url: "https://flagcdn.com/w320/bq.png",
      bilgi: false,
      bm: false,
      enlem: 12.18,
      boylam: -68.25,
      dosyaboyut: 2386
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guyana.png",
      trisim: "Guyana",
      enisim: "Guyana",
      isim: "Guyana",
      baskent: "Georgetown",
      kita: "Americas",
      url: "https://flagcdn.com/w320/gy.png",
      bilgi: false,
      bm: true,
      enlem: 5,
      boylam: -59,
      dosyaboyut: 1438
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/amerikabirlesikdevletlerikucukdisadalari.png",
      trisim: "Amerikabirleikdevletlerikkdadalar",
      enisim: "Unitedstatesminoroutlyingislands",
      isim: "Amerikabirlesikdevletlerikucukdisadalari",
      baskent: "Washingtondc",
      kita: "Americas",
      url: "https://flagcdn.com/w320/um.png",
      bilgi: false,
      bm: false,
      enlem: 19.3,
      boylam: 166.63,
      dosyaboyut: 1289
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ermenistan.png",
      trisim: "Ermenistan",
      enisim: "Armenia",
      isim: "Ermenistan",
      baskent: "Yerevan",
      kita: "Asia",
      url: "https://flagcdn.com/w320/am.png",
      bilgi: false,
      bm: true,
      enlem: 40,
      boylam: 45,
      dosyaboyut: 198
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/lubnan.png",
      trisim: "Lbnan",
      enisim: "Lebanon",
      isim: "Lubnan",
      baskent: "Beirut",
      kita: "Asia",
      url: "https://flagcdn.com/w320/lb.png",
      bilgi: false,
      bm: true,
      enlem: 33.83,
      boylam: 35.83,
      dosyaboyut: 1239
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/karadag.png",
      trisim: "Karada",
      enisim: "Montenegro",
      isim: "Karadag",
      baskent: "Podgorica",
      kita: "Europe",
      url: "https://flagcdn.com/w320/me.png",
      bilgi: false,
      bm: true,
      enlem: 42.5,
      boylam: 19.3,
      dosyaboyut: 3568
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/gronland.png",
      trisim: "Grnland",
      enisim: "Greenland",
      isim: "Gronland",
      baskent: "Nuuk",
      kita: "Americas",
      url: "https://flagcdn.com/w320/gl.png",
      bilgi: false,
      bm: false,
      enlem: 72,
      boylam: -40,
      dosyaboyut: 1104
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/papuayenigine.png",
      trisim: "Papuayenigine",
      enisim: "Papuanewguinea",
      isim: "Papuayenigine",
      baskent: "Port moresby",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/pg.png",
      bilgi: false,
      bm: true,
      enlem: -6,
      boylam: 147,
      dosyaboyut: 2772
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/zambiya.png",
      trisim: "Zambiya",
      enisim: "Zambia",
      isim: "Zambiya",
      baskent: "Lusaka",
      kita: "Africa",
      url: "https://flagcdn.com/w320/zm.png",
      bilgi: false,
      bm: true,
      enlem: -15,
      boylam: 30,
      dosyaboyut: 1062
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/trinidadvetobago.png",
      trisim: "Trinidadvetobago",
      enisim: "Trinidadandtobago",
      isim: "Trinidadvetobago",
      baskent: "Port Of Spain",
      kita: "Americas",
      url: "https://flagcdn.com/w320/tt.png",
      bilgi: false,
      bm: true,
      enlem: 10.69,
      boylam: -61.22,
      dosyaboyut: 1236
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/fransizguneyveantarktikatopraklari.png",
      trisim: "Franszgneyveantarktikatopraklar",
      enisim: "Frenchsouthernandantarcticlands",
      isim: "Fransizguneyveantarktikatopraklari",
      baskent: "Port-aux-Français",
      kita: "Antarctic",
      url: "https://flagcdn.com/w320/tf.png",
      bilgi: false,
      bm: false,
      enlem: -49.25,
      boylam: 69.17,
      dosyaboyut: 1257
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/peru.png",
      trisim: "Peru",
      enisim: "Peru",
      isim: "Peru",
      baskent: "Lima",
      kita: "Americas",
      url: "https://flagcdn.com/w320/pe.png",
      bilgi: false,
      bm: true,
      enlem: -10,
      boylam: -76,
      dosyaboyut: 172
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/isvec.png",
      trisim: "Sve",
      enisim: "Sweden",
      isim: "Isvec",
      baskent: "Stockholm",
      kita: "Europe",
      url: "https://flagcdn.com/w320/se.png",
      bilgi: false,
      bm: true,
      enlem: 62,
      boylam: 15,
      dosyaboyut: 142
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sudan.png",
      trisim: "Sudan",
      enisim: "Sudan",
      isim: "Sudan",
      baskent: "Khartoum",
      kita: "Africa",
      url: "https://flagcdn.com/w320/sd.png",
      bilgi: false,
      bm: true,
      enlem: 15,
      boylam: 30,
      dosyaboyut: 744
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/saintpierrevemiquelon.png",
      trisim: "Saintpierrevemiquelon",
      enisim: "Saintpierreandmiquelon",
      isim: "Saintpierrevemiquelon",
      baskent: "Saint-pierre",
      kita: "Americas",
      url: "https://flagcdn.com/w320/pm.png",
      bilgi: false,
      bm: false,
      enlem: 46.83,
      boylam: -56.33,
      dosyaboyut: 14300
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/umman.png",
      trisim: "Umman",
      enisim: "Oman",
      isim: "Umman",
      baskent: "Muscat",
      kita: "Asia",
      url: "https://flagcdn.com/w320/om.png",
      bilgi: false,
      bm: true,
      enlem: 21,
      boylam: 57,
      dosyaboyut: 789
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/hindistan.png",
      trisim: "Hindistan",
      enisim: "India",
      isim: "Hindistan",
      baskent: "Newdelhi",
      kita: "Asia",
      url: "https://flagcdn.com/w320/in.png",
      bilgi: false,
      bm: true,
      enlem: 20,
      boylam: 77,
      dosyaboyut: 1254
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tayvan.png",
      trisim: "Tayvan",
      enisim: "Taiwan",
      isim: "Tayvan",
      baskent: "Taipei",
      kita: "Asia",
      url: "https://flagcdn.com/w320/tw.png",
      bilgi: false,
      bm: false,
      enlem: 23.5,
      boylam: 121,
      dosyaboyut: 1352
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/mogolistan.png",
      trisim: "Moolistan",
      enisim: "Mongolia",
      isim: "Mogolistan",
      baskent: "Ulanbator",
      kita: "Asia",
      url: "https://flagcdn.com/w320/mn.png",
      bilgi: false,
      bm: true,
      enlem: 46,
      boylam: 105,
      dosyaboyut: 796
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/senegal.png",
      trisim: "Senegal",
      enisim: "Senegal",
      isim: "Senegal",
      baskent: "Dakar",
      kita: "Africa",
      url: "https://flagcdn.com/w320/sn.png",
      bilgi: false,
      bm: true,
      enlem: 14,
      boylam: -14,
      dosyaboyut: 681
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tanzanya.png",
      trisim: "Tanzanya",
      enisim: "Tanzania",
      isim: "Tanzanya",
      baskent: "Dodoma",
      kita: "Africa",
      url: "https://flagcdn.com/w320/tz.png",
      bilgi: false,
      bm: true,
      enlem: -6,
      boylam: 35,
      dosyaboyut: 1191
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kanada.png",
      trisim: "Kanada",
      enisim: "Canada",
      isim: "Kanada",
      baskent: "Ottawa",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ca.png",
      bilgi: false,
      bm: true,
      enlem: 60,
      boylam: -95,
      dosyaboyut: 1317
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kostarika.png",
      trisim: "Kostarika",
      enisim: "Costarica",
      isim: "Kostarika",
      baskent: "SanjosÚ",
      kita: "Americas",
      url: "https://flagcdn.com/w320/cr.png",
      bilgi: false,
      bm: true,
      enlem: 10,
      boylam: -84,
      dosyaboyut: 1665
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cin.png",
      trisim: "In",
      enisim: "China",
      isim: "Cin",
      baskent: "Beijing",
      kita: "Asia",
      url: "https://flagcdn.com/w320/cn.png",
      bilgi: false,
      bm: true,
      enlem: 35,
      boylam: 105,
      dosyaboyut: 955
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kolombiya.png",
      trisim: "Kolombiya",
      enisim: "Colombia",
      isim: "Kolombiya",
      baskent: "Bogotß",
      kita: "Americas",
      url: "https://flagcdn.com/w320/co.png",
      bilgi: false,
      bm: true,
      enlem: 4,
      boylam: -72,
      dosyaboyut: 231
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/myanmar.png",
      trisim: "Myanmar",
      enisim: "Myanmar",
      isim: "Myanmar",
      baskent: "Naypyidaw",
      kita: "Asia",
      url: "https://flagcdn.com/w320/mm.png",
      bilgi: false,
      bm: true,
      enlem: 22,
      boylam: 98,
      dosyaboyut: 1315
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/rusya.png",
      trisim: "Rusya",
      enisim: "Russia",
      isim: "Rusya",
      baskent: "Moscow",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ru.png",
      bilgi: false,
      bm: true,
      enlem: 60,
      boylam: 100,
      dosyaboyut: 153
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kuzeykore.png",
      trisim: "Kuzeykore",
      enisim: "Northkorea",
      isim: "Kuzeykore",
      baskent: "Pyongyang",
      kita: "Asia",
      url: "https://flagcdn.com/w320/kp.png",
      bilgi: false,
      bm: true,
      enlem: 40,
      boylam: 127,
      dosyaboyut: 1133
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/caymanadalari.png",
      trisim: "Caymanadalar",
      enisim: "Caymanislands",
      isim: "Caymanadalari",
      baskent: "Georgetown",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ky.png",
      bilgi: false,
      bm: false,
      enlem: 19.31,
      boylam: -81.25,
      dosyaboyut: 4625
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bouvetadasi.png",
      trisim: "Bouvetadas",
      enisim: "Bouvetisland",
      isim: "Bouvetadasi",
      baskent: "Bouvetadasi",
      kita: "Antarctic",
      url: "https://flagcdn.com/w320/bv.png",
      bilgi: false,
      bm: false,
      enlem: 54.42,
      boylam: 3.35,
      dosyaboyut: 323
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/belarus.png",
      trisim: "Belarus",
      enisim: "Belarus",
      isim: "Belarus",
      baskent: "Minsk",
      kita: "Europe",
      url: "https://flagcdn.com/w320/by.png",
      bilgi: false,
      bm: true,
      enlem: 53,
      boylam: 28,
      dosyaboyut: 1717
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/portekiz.png",
      trisim: "Portekiz",
      enisim: "Portugal",
      isim: "Portekiz",
      baskent: "Lisbon",
      kita: "Europe",
      url: "https://flagcdn.com/w320/pt.png",
      bilgi: false,
      bm: true,
      enlem: 39.5,
      boylam: -8,
      dosyaboyut: 4980
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/esvatini.png",
      trisim: "Esvatini",
      enisim: "Eswatini",
      isim: "Esvatini",
      baskent: "Mbabane",
      kita: "Africa",
      url: "https://flagcdn.com/w320/sz.png",
      bilgi: false,
      bm: true,
      enlem: -26.5,
      boylam: 31.5,
      dosyaboyut: 2803
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/polonya.png",
      trisim: "Polonya",
      enisim: "Poland",
      isim: "Polonya",
      baskent: "Varşova",
      kita: "Europe",
      url: "https://flagcdn.com/w320/pl.png",
      bilgi: false,
      bm: true,
      enlem: 52,
      boylam: 20,
      dosyaboyut: 119
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/isvicre.png",
      trisim: "Svire",
      enisim: "Switzerland",
      isim: "Isvicre",
      baskent: "Bern",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ch.png",
      bilgi: false,
      bm: true,
      enlem: 47,
      boylam: 8,
      dosyaboyut: 154
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kongocumhuriyeti.png",
      trisim: "Kongocumhuriyeti",
      enisim: "Republicofthecongo",
      isim: "Kongocumhuriyeti",
      baskent: "Brazzaville",
      kita: "Africa",
      url: "https://flagcdn.com/w320/cg.png",
      bilgi: false,
      bm: true,
      enlem: -1,
      boylam: 15,
      dosyaboyut: 980
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/venezuela.png",
      trisim: "Venezuela",
      enisim: "Venezuela",
      isim: "Venezuela",
      baskent: "Caracas",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ve.png",
      bilgi: false,
      bm: true,
      enlem: 8,
      boylam: -66,
      dosyaboyut: 906
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/panama.png",
      trisim: "Panama",
      enisim: "Panama",
      isim: "Panama",
      baskent: "Panamacity",
      kita: "Americas",
      url: "https://flagcdn.com/w320/pa.png",
      bilgi: false,
      bm: true,
      enlem: 9,
      boylam: -80,
      dosyaboyut: 1123
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/hollanda.png",
      trisim: "Hollanda",
      enisim: "Netherlands",
      isim: "Hollanda",
      baskent: "Amsterdam",
      kita: "Europe",
      url: "https://flagcdn.com/w320/nl.png",
      bilgi: false,
      bm: true,
      enlem: 52.5,
      boylam: 5.75,
      dosyaboyut: 153
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bagimsizsamoadevleti.png",
      trisim: "Bamszsamoadevleti",
      enisim: "Samoa",
      isim: "Bagimsizsamoadevleti",
      baskent: "Apia",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/ws.png",
      bilgi: false,
      bm: true,
      enlem: -13.58,
      boylam: -172.33,
      dosyaboyut: 699
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/danimarka.png",
      trisim: "Danimarka",
      enisim: "Denmark",
      isim: "Danimarka",
      baskent: "Copenhagen",
      kita: "Europe",
      url: "https://flagcdn.com/w320/dk.png",
      bilgi: false,
      bm: true,
      enlem: 56,
      boylam: 10,
      dosyaboyut: 292
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/luksemburg.png",
      trisim: "Lksemburg",
      enisim: "Luxembourg",
      isim: "Luksemburg",
      baskent: "Luxembourg",
      kita: "Europe",
      url: "https://flagcdn.com/w320/lu.png",
      bilgi: false,
      bm: true,
      enlem: 49.75,
      boylam: 6.17,
      dosyaboyut: 151
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/faroeadalari.png",
      trisim: "Faroeadalar",
      enisim: "Faroeislands",
      isim: "Faroeadalari",
      baskent: "Tórshavn",
      kita: "Europe",
      url: "https://flagcdn.com/w320/fo.png",
      bilgi: false,
      bm: false,
      enlem: 62,
      boylam: -7,
      dosyaboyut: 321
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/slovenya.png",
      trisim: "Slovenya",
      enisim: "Slovenia",
      isim: "Slovenya",
      baskent: "Lübliyana",
      kita: "Europe",
      url: "https://flagcdn.com/w320/si.png",
      bilgi: false,
      bm: true,
      enlem: 46.12,
      boylam: 14.82,
      dosyaboyut: 930
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/togo.png",
      trisim: "Togo",
      enisim: "Togo",
      isim: "Togo",
      baskent: "LomÚ",
      kita: "Africa",
      url: "https://flagcdn.com/w320/tg.png",
      bilgi: false,
      bm: true,
      enlem: 8,
      boylam: 1.17,
      dosyaboyut: 751
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tayland.png",
      trisim: "Tayland",
      enisim: "Thailand",
      isim: "Tayland",
      baskent: "Bangkok",
      kita: "Asia",
      url: "https://flagcdn.com/w320/th.png",
      bilgi: false,
      bm: true,
      enlem: 15,
      boylam: 100,
      dosyaboyut: 172
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/wallisvefutunaadalaribolgesi.png",
      trisim: "Wallisvefutunaadalarblgesi",
      enisim: "Wallisandfutuna",
      isim: "Wallisvefutunaadalaribolgesi",
      baskent: "Matautu",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/wf.png",
      bilgi: false,
      bm: false,
      enlem: -13.3,
      boylam: -176.2,
      dosyaboyut: 669
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bahamalar.png",
      trisim: "Bahamalar",
      enisim: "Bahamas",
      isim: "Bahamalar",
      baskent: "Nassau",
      kita: "Americas",
      url: "https://flagcdn.com/w320/bs.png",
      bilgi: false,
      bm: true,
      enlem: 25.03,
      boylam: -77.4,
      dosyaboyut: 735
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tonga.png",
      trisim: "Tonga",
      enisim: "Tonga",
      isim: "Tonga",
      baskent: "Nukualofa",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/to.png",
      bilgi: false,
      bm: true,
      enlem: -20,
      boylam: -175,
      dosyaboyut: 163
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/yunanistan.png",
      trisim: "Yunanistan",
      enisim: "Greece",
      isim: "Yunanistan",
      baskent: "Athens",
      kita: "Europe",
      url: "https://flagcdn.com/w320/gr.png",
      bilgi: false,
      bm: true,
      enlem: 39,
      boylam: 22,
      dosyaboyut: 306
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sanmarino.png",
      trisim: "Sanmarino",
      enisim: "Sanmarino",
      isim: "Sanmarino",
      baskent: "San Marino",
      kita: "Europe",
      url: "https://flagcdn.com/w320/sm.png",
      bilgi: false,
      bm: true,
      enlem: 43.77,
      boylam: 12.42,
      dosyaboyut: 7872
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/reunion.png",
      trisim: "Reunion",
      enisim: "Reunion",
      isim: "Reunion",
      baskent: "Saintdenis",
      kita: "Africa",
      url: "https://flagcdn.com/w320/re.png",
      bilgi: false,
      bm: false,
      enlem: -21.15,
      boylam: 55.5,
      dosyaboyut: 2106
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/vatikan.png",
      trisim: "Vatikan",
      enisim: "Vaticancity",
      isim: "Vatikan",
      baskent: "Vatikan",
      kita: "Europe",
      url: "https://flagcdn.com/w320/va.png",
      bilgi: false,
      bm: false,
      enlem: 41.9,
      boylam: 12.45,
      dosyaboyut: 7956
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/burundi.png",
      trisim: "Burundi",
      enisim: "Burundi",
      isim: "Burundi",
      baskent: "Gitega",
      kita: "Africa",
      url: "https://flagcdn.com/w320/bi.png",
      bilgi: false,
      bm: true,
      enlem: -3.5,
      boylam: 30,
      dosyaboyut: 1841
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bahreyn.png",
      trisim: "Bahreyn",
      enisim: "Bahrain",
      isim: "Bahreyn",
      baskent: "Manama",
      kita: "Asia",
      url: "https://flagcdn.com/w320/bh.png",
      bilgi: false,
      bm: true,
      enlem: 26,
      boylam: 50.55,
      dosyaboyut: 827
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/marshalladalari.png",
      trisim: "Marshalladalar",
      enisim: "Marshallislands",
      isim: "Marshalladalari",
      baskent: "Majuro",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/mh.png",
      bilgi: false,
      bm: true,
      enlem: 9,
      boylam: 168,
      dosyaboyut: 2699
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/turksvecaicosadalari.png",
      trisim: "Turksvecaicosadalar",
      enisim: "Turksandcaicosislands",
      isim: "Turksvecaicosadalari",
      baskent: "Cockburntown",
      kita: "Americas",
      url: "https://flagcdn.com/w320/tc.png",
      bilgi: false,
      bm: false,
      enlem: 21.75,
      boylam: -71.58,
      dosyaboyut: 2293
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/manadasi.png",
      trisim: "Manadas",
      enisim: "Isleofman",
      isim: "Manadasi",
      baskent: "Douglas",
      kita: "Europe",
      url: "https://flagcdn.com/w320/im.png",
      bilgi: false,
      bm: false,
      enlem: 54.25,
      boylam: -4.5,
      dosyaboyut: 2201
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/haiti.png",
      trisim: "Haiti",
      enisim: "Haiti",
      isim: "Haiti",
      baskent: "Portauprince",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ht.png",
      bilgi: false,
      bm: true,
      enlem: 19,
      boylam: -72.42,
      dosyaboyut: 1972
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/afganistan.png",
      trisim: "Afganistan",
      enisim: "Afghanistan",
      isim: "Afganistan",
      baskent: "Kabil",
      kita: "Asia",
      url: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_the_Taliban.svg/320px-Flag_of_the_Taliban.svg.png",
      bilgi: false,
      bm: true,
      enlem: 33,
      boylam: 65,
      dosyaboyut: 8285
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/israil.png",
      trisim: "Srail",
      enisim: "Israel",
      isim: "Israil",
      baskent: "Tel Aviv",
      kita: "Asia",
      url: "https://flagcdn.com/w320/il.png",
      bilgi: false,
      bm: true,
      enlem: 31.47,
      boylam: 35.13,
      dosyaboyut: 893
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/libya.png",
      trisim: "Libya",
      enisim: "Libya",
      isim: "Libya",
      baskent: "Tripoli",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ly.png",
      bilgi: false,
      bm: true,
      enlem: 25,
      boylam: 17,
      dosyaboyut: 579
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/uruguay.png",
      trisim: "Uruguay",
      enisim: "Uruguay",
      isim: "Uruguay",
      baskent: "Montevideo",
      kita: "Americas",
      url: "https://flagcdn.com/w320/uy.png",
      bilgi: false,
      bm: true,
      enlem: -33,
      boylam: -56,
      dosyaboyut: 2392
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/norfolkadasi.png",
      trisim: "Norfolkadas",
      enisim: "Norfolkisland",
      isim: "Norfolkadasi",
      baskent: "Kingston",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/nf.png",
      bilgi: false,
      bm: false,
      enlem: -29.03,
      boylam: 167.95,
      dosyaboyut: 2349
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/nikaragua.png",
      trisim: "Nikaragua",
      enisim: "Nicaragua",
      isim: "Nikaragua",
      baskent: "Managua",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ni.png",
      bilgi: false,
      bm: true,
      enlem: 13,
      boylam: -85,
      dosyaboyut: 1481
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cookadalari.png",
      trisim: "Cookadalar",
      enisim: "Cookislands",
      isim: "Cookadalari",
      baskent: "Avarua",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/ck.png",
      bilgi: false,
      bm: false,
      enlem: -21.23,
      boylam: -159.77,
      dosyaboyut: 2699
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/laos.png",
      trisim: "Laos",
      enisim: "Laos",
      isim: "Laos",
      baskent: "Vientiane",
      kita: "Asia",
      url: "https://flagcdn.com/w320/la.png",
      bilgi: false,
      bm: true,
      enlem: 18,
      boylam: 105,
      dosyaboyut: 666
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/christmasadasi.png",
      trisim: "Christmasadas",
      enisim: "Christmasisland",
      isim: "Christmasadasi",
      baskent: "Flyingfishcove",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/cx.png",
      bilgi: false,
      bm: false,
      enlem: -10.5,
      boylam: 105.67,
      dosyaboyut: 2256
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sainthelena.png",
      trisim: "Sainthelena",
      enisim: "Sainthelenaascensionandtristandacunha",
      isim: "Sainthelena",
      baskent: "Jamestown",
      kita: "Africa",
      url: "https://flagcdn.com/w320/sh.png",
      bilgi: false,
      bm: false,
      enlem: -15.95,
      boylam: -5.72,
      dosyaboyut: 2484
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/anguilla.png",
      trisim: "Anguilla",
      enisim: "Anguilla",
      isim: "Anguilla",
      baskent: "Thevalley",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ai.png",
      bilgi: false,
      bm: false,
      enlem: 18.25,
      boylam: -63.17,
      dosyaboyut: 1929
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/mikronezya.png",
      trisim: "Mikronezya",
      enisim: "Micronesia",
      isim: "Mikronezya",
      baskent: "Palikir",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/fm.png",
      bilgi: false,
      bm: true,
      enlem: 6.92,
      boylam: 158.25,
      dosyaboyut: 676
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/almanya.png",
      trisim: "Almanya",
      enisim: "Germany",
      isim: "Almanya",
      baskent: "Berlin",
      kita: "Europe",
      url: "https://flagcdn.com/w320/de.png",
      bilgi: false,
      bm: true,
      enlem: 51,
      boylam: 9,
      dosyaboyut: 151
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guam.png",
      trisim: "Guam",
      enisim: "Guam",
      isim: "Guam",
      baskent: "HagÕt±a",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/gu.png",
      bilgi: false,
      bm: false,
      enlem: 13.47,
      boylam: 144.78,
      dosyaboyut: 2205
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/kiribati.png",
      trisim: "Kiribati",
      enisim: "Kiribati",
      isim: "Kiribati",
      baskent: "Southtarawa",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/ki.png",
      bilgi: false,
      bm: true,
      enlem: 1.42,
      boylam: 173,
      dosyaboyut: 3872
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sintmaarten.png",
      trisim: "Sintmaarten",
      enisim: "Sintmaarten",
      isim: "Sintmaarten",
      baskent: "Philipsburg",
      kita: "Americas",
      url: "https://flagcdn.com/w320/sx.png",
      bilgi: false,
      bm: false,
      enlem: 18.03,
      boylam: -63.05,
      dosyaboyut: 3972
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ispanya.png",
      trisim: "Spanya",
      enisim: "Spain",
      isim: "Ispanya",
      baskent: "Madrid",
      kita: "Europe",
      url: "https://flagcdn.com/w320/es.png",
      bilgi: false,
      bm: true,
      enlem: 40,
      boylam: -4,
      dosyaboyut: 3623
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/jamaika.png",
      trisim: "Jamaika",
      enisim: "Jamaica",
      isim: "Jamaika",
      baskent: "Kingston",
      kita: "Americas",
      url: "https://flagcdn.com/w320/jm.png",
      bilgi: false,
      bm: true,
      enlem: 18.25,
      boylam: -77.5,
      dosyaboyut: 972
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/filistin.png",
      trisim: "Filistin",
      enisim: "Palestine",
      isim: "Filistin",
      baskent: "Ramallahjerusalem",
      kita: "Asia",
      url: "https://flagcdn.com/w320/ps.png",
      bilgi: false,
      bm: false,
      enlem: 31.9,
      boylam: 35.2,
      dosyaboyut: 689
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/fransizguyanasi.png",
      trisim: "Franszguyanas",
      enisim: "Frenchguiana",
      isim: "Fransizguyanasi",
      baskent: "Cayenne",
      kita: "Americas",
      url: "https://flagcdn.com/w320/gf.png",
      bilgi: false,
      bm: false,
      enlem: 4,
      boylam: -53,
      dosyaboyut: 1316
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/andorra.png",
      trisim: "Andorra",
      enisim: "Andorra",
      isim: "Andorra",
      baskent: "Andorralavella",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ad.png",
      bilgi: false,
      bm: true,
      enlem: 42.5,
      boylam: 1.5,
      dosyaboyut: 3895
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sili.png",
      trisim: "Ili",
      enisim: "Chile",
      isim: "Sili",
      baskent: "Santiago",
      kita: "Americas",
      url: "https://flagcdn.com/w320/cl.png",
      bilgi: false,
      bm: true,
      enlem: -30,
      boylam: -71,
      dosyaboyut: 578
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/lesotho.png",
      trisim: "Lesotho",
      enisim: "Lesotho",
      isim: "Lesotho",
      baskent: "Maseru",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ls.png",
      bilgi: false,
      bm: true,
      enlem: -29.5,
      boylam: 28.5,
      dosyaboyut: 1065
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/avustralya.png",
      trisim: "Avustralya",
      enisim: "Australia",
      isim: "Avustralya",
      baskent: "Canberra",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/au.png",
      bilgi: false,
      bm: true,
      enlem: -27,
      boylam: 133,
      dosyaboyut: 1618
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/grenada.png",
      trisim: "Grenada",
      enisim: "Grenada",
      isim: "Grenada",
      baskent: "Stgeorges",
      kita: "Americas",
      url: "https://flagcdn.com/w320/gd.png",
      bilgi: false,
      bm: true,
      enlem: 12.12,
      boylam: -61.67,
      dosyaboyut: 1950
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/gana.png",
      trisim: "Gana",
      enisim: "Ghana",
      isim: "Gana",
      baskent: "Accra",
      kita: "Africa",
      url: "https://flagcdn.com/w320/gh.png",
      bilgi: false,
      bm: true,
      enlem: 8,
      boylam: -2,
      dosyaboyut: 639
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/seyseller.png",
      trisim: "Seyeller",
      enisim: "Seychelles",
      isim: "Seyseller",
      baskent: "Victoria",
      kita: "Africa",
      url: "https://flagcdn.com/w320/sc.png",
      bilgi: false,
      bm: true,
      enlem: -4.58,
      boylam: 55.67,
      dosyaboyut: 1411
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/angola.png",
      trisim: "Angola",
      enisim: "Angola",
      isim: "Angola",
      baskent: "Luanda",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ao.png",
      bilgi: false,
      bm: true,
      enlem: -12.5,
      boylam: 18.5,
      dosyaboyut: 1581
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/bermuda.png",
      trisim: "Bermuda",
      enisim: "Bermuda",
      isim: "Bermuda",
      baskent: "Hamilton",
      kita: "Americas",
      url: "https://flagcdn.com/w320/bm.png",
      bilgi: false,
      bm: false,
      enlem: 32.33,
      boylam: -64.75,
      dosyaboyut: 3942
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/pakistan.png",
      trisim: "Pakistan",
      enisim: "Pakistan",
      isim: "Pakistan",
      baskent: "Islamabad",
      kita: "Asia",
      url: "https://flagcdn.com/w320/pk.png",
      bilgi: false,
      bm: true,
      enlem: 30,
      boylam: 70,
      dosyaboyut: 1281
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/mali.png",
      trisim: "Mali",
      enisim: "Mali",
      isim: "Mali",
      baskent: "Bamako",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ml.png",
      bilgi: false,
      bm: true,
      enlem: 17,
      boylam: -4,
      dosyaboyut: 253
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/suudiarabistan.png",
      trisim: "Suudiarabistan",
      enisim: "Saudiarabia",
      isim: "Suudiarabistan",
      baskent: "Riyadh",
      kita: "Asia",
      url: "https://flagcdn.com/w320/sa.png",
      bilgi: false,
      bm: true,
      enlem: 25,
      boylam: 45,
      dosyaboyut: 3003
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/curacao.png",
      trisim: "Curaao",
      enisim: "Curaao",
      isim: "Curacao",
      baskent: "Willemstad",
      kita: "Americas",
      url: "https://flagcdn.com/w320/cw.png",
      bilgi: false,
      bm: false,
      enlem: 12.12,
      boylam: -68.93,
      dosyaboyut: 643
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guneykore.png",
      trisim: "Gneykore",
      enisim: "Southkorea",
      isim: "Guneykore",
      baskent: "Seoul",
      kita: "Asia",
      url: "https://flagcdn.com/w320/kr.png",
      bilgi: false,
      bm: true,
      enlem: 37,
      boylam: 127.5,
      dosyaboyut: 2667
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/etiyopya.png",
      trisim: "Etiyopya",
      enisim: "Ethiopia",
      isim: "Etiyopya",
      baskent: "Addisababa",
      kita: "Africa",
      url: "https://flagcdn.com/w320/et.png",
      bilgi: false,
      bm: true,
      enlem: 8,
      boylam: 38,
      dosyaboyut: 1887
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/guadeloupe.png",
      trisim: "Guadeloupe",
      enisim: "Guadeloupe",
      isim: "Guadeloupe",
      baskent: "Basseterre",
      kita: "Americas",
      url: "https://flagcdn.com/w320/gp.png",
      bilgi: false,
      bm: false,
      enlem: 16.25,
      boylam: -61.58,
      dosyaboyut: 5294
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/banglades.png",
      trisim: "Banglade",
      enisim: "Bangladesh",
      isim: "Banglades",
      baskent: "Dhaka",
      kita: "Asia",
      url: "https://flagcdn.com/w320/bd.png",
      bilgi: false,
      bm: true,
      enlem: 24,
      boylam: 90,
      dosyaboyut: 807
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/yenizelanda.png",
      trisim: "Yenizelanda",
      enisim: "Newzealand",
      isim: "Yenizelanda",
      baskent: "Wellington",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/nz.png",
      bilgi: false,
      bm: true,
      enlem: -41,
      boylam: 174,
      dosyaboyut: 1564
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/komorlar.png",
      trisim: "Komorlar",
      enisim: "Comoros",
      isim: "Komorlar",
      baskent: "Moroni",
      kita: "Africa",
      url: "https://flagcdn.com/w320/km.png",
      bilgi: false,
      bm: true,
      enlem: -12.17,
      boylam: 44.25,
      dosyaboyut: 1587
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/belize.png",
      trisim: "Belize",
      enisim: "Belize",
      isim: "Belize",
      baskent: "Belmopan",
      kita: "Americas",
      url: "https://flagcdn.com/w320/bz.png",
      bilgi: false,
      bm: true,
      enlem: 17.25,
      boylam: -88.75,
      dosyaboyut: 6797
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/uganda.png",
      trisim: "Uganda",
      enisim: "Uganda",
      isim: "Uganda",
      baskent: "Kampala",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ug.png",
      bilgi: false,
      bm: true,
      enlem: 1,
      boylam: 32,
      dosyaboyut: 1457
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/singapur.png",
      trisim: "Singapur",
      enisim: "Singapore",
      isim: "Singapur",
      baskent: "Singapore",
      kita: "Asia",
      url: "https://flagcdn.com/w320/sg.png",
      bilgi: false,
      bm: true,
      enlem: 1.37,
      boylam: 103.8,
      dosyaboyut: 974
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/lihtenstayn.png",
      trisim: "Lihtentayn",
      enisim: "Liechtenstein",
      isim: "Lihtenstayn",
      baskent: "Vaduz",
      kita: "Europe",
      url: "https://flagcdn.com/w320/li.png",
      bilgi: false,
      bm: true,
      enlem: 47.27,
      boylam: 9.53,
      dosyaboyut: 1336
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/macaristan.png",
      trisim: "Macaristan",
      enisim: "Hungary",
      isim: "Macaristan",
      baskent: "Budapeşte",
      kita: "Europe",
      url: "https://flagcdn.com/w320/hu.png",
      bilgi: false,
      bm: true,
      enlem: 47,
      boylam: 20,
      dosyaboyut: 199
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/izlanda.png",
      trisim: "Zlanda",
      enisim: "Iceland",
      isim: "Izlanda",
      baskent: "Reykjavik",
      kita: "Europe",
      url: "https://flagcdn.com/w320/is.png",
      bilgi: false,
      bm: true,
      enlem: 65,
      boylam: -18,
      dosyaboyut: 330
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/tacikistan.png",
      trisim: "Tacikistan",
      enisim: "Tajikistan",
      isim: "Tacikistan",
      baskent: "Dushanbe",
      kita: "Asia",
      url: "https://flagcdn.com/w320/tj.png",
      bilgi: false,
      bm: true,
      enlem: 39,
      boylam: 71,
      dosyaboyut: 874
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/namibya.png",
      trisim: "Namibya",
      enisim: "Namibia",
      isim: "Namibya",
      baskent: "Windhoek",
      kita: "Africa",
      url: "https://flagcdn.com/w320/na.png",
      bilgi: false,
      bm: true,
      enlem: -22,
      boylam: 17,
      dosyaboyut: 1896
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/dogutimor.png",
      trisim: "Doutimor",
      enisim: "Timorleste",
      isim: "Dogutimor",
      baskent: "Dili",
      kita: "Asia",
      url: "https://flagcdn.com/w320/tl.png",
      bilgi: false,
      bm: true,
      enlem: -8.83,
      boylam: 125.92,
      dosyaboyut: 1305
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/misir.png",
      trisim: "Msr",
      enisim: "Egypt",
      isim: "Misir",
      baskent: "Kahire",
      kita: "Africa",
      url: "https://flagcdn.com/w320/eg.png",
      bilgi: false,
      bm: true,
      enlem: 27,
      boylam: 30,
      dosyaboyut: 1198
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/sirbistan.png",
      trisim: "Srbistan",
      enisim: "Serbia",
      isim: "Sirbistan",
      baskent: "Belgrade",
      kita: "Europe",
      url: "https://flagcdn.com/w320/rs.png",
      bilgi: false,
      bm: true,
      enlem: 44,
      boylam: 21,
      dosyaboyut: 6204
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/mauritius.png",
      trisim: "Mauritius",
      enisim: "Mauritius",
      isim: "Mauritius",
      baskent: "Portlouis",
      kita: "Africa",
      url: "https://flagcdn.com/w320/mu.png",
      bilgi: false,
      bm: true,
      enlem: -20.28,
      boylam: 57.55,
      dosyaboyut: 245
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/makao.png",
      trisim: "Makao",
      enisim: "Macau",
      isim: "Makao",
      baskent: "Makao",
      kita: "Asia",
      url: "https://flagcdn.com/w320/mo.png",
      bilgi: false,
      bm: false,
      enlem: 22.17,
      boylam: 113.55,
      dosyaboyut: 2255
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/fransizpolinezyasi.png",
      trisim: "Franszpolinezyas",
      enisim: "Frenchpolynesia",
      isim: "Fransizpolinezyasi",
      baskent: "Papeete",
      kita: "Oceania",
      url: "https://flagcdn.com/w320/pf.png",
      bilgi: false,
      bm: false,
      enlem: 17.68,
      boylam: 149.41,
      dosyaboyut: 2561
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/maldivler.png",
      trisim: "Maldivler",
      enisim: "Maldives",
      isim: "Maldivler",
      baskent: "Male",
      kita: "Asia",
      url: "https://flagcdn.com/w320/mv.png",
      bilgi: false,
      bm: true,
      enlem: 3.25,
      boylam: 73,
      dosyaboyut: 704
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/endonezya.png",
      trisim: "Endonezya",
      enisim: "Indonesia",
      isim: "Endonezya",
      baskent: "Jakarta",
      kita: "Asia",
      url: "https://flagcdn.com/w320/id.png",
      bilgi: false,
      bm: true,
      enlem: -5,
      boylam: 120,
      dosyaboyut: 146
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/demokratikkongocumhuriyeti.png",
      trisim: "Demokratikkongocumhuriyeti",
      enisim: "Drcongo",
      isim: "Demokratikkongocumhuriyeti",
      baskent: "Kinshasa",
      kita: "Africa",
      url: "https://flagcdn.com/w320/cd.png",
      bilgi: false,
      bm: true,
      enlem: 0,
      boylam: 25,
      dosyaboyut: 1486
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/estonya.png",
      trisim: "Estonya",
      enisim: "Estonia",
      isim: "Estonya",
      baskent: "Tallinn",
      kita: "Europe",
      url: "https://flagcdn.com/w320/ee.png",
      bilgi: false,
      bm: true,
      enlem: 59,
      boylam: 26,
      dosyaboyut: 153
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/vietnam.png",
      trisim: "Vietnam",
      enisim: "Vietnam",
      isim: "Vietnam",
      baskent: "Hanoi",
      kita: "Asia",
      url: "https://flagcdn.com/w320/vn.png",
      bilgi: false,
      bm: true,
      enlem: 16.17,
      boylam: 107.83,
      dosyaboyut: 913
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/italya.png",
      trisim: "Talya",
      enisim: "Italy",
      isim: "Italya",
      baskent: "Rome",
      kita: "Europe",
      url: "https://flagcdn.com/w320/it.png",
      bilgi: false,
      bm: true,
      enlem: 42.83,
      boylam: 12.83,
      dosyaboyut: 253
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/gine.png",
      trisim: "Gine",
      enisim: "Guinea",
      isim: "Gine",
      baskent: "Conakry",
      kita: "Africa",
      url: "https://flagcdn.com/w320/gn.png",
      bilgi: false,
      bm: true,
      enlem: 11,
      boylam: -10,
      dosyaboyut: 253
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/cad.png",
      trisim: "Ad",
      enisim: "Chad",
      isim: "Cad",
      baskent: "Ndjamena",
      kita: "Africa",
      url: "https://flagcdn.com/w320/td.png",
      bilgi: false,
      bm: true,
      enlem: 15,
      boylam: 19,
      dosyaboyut: 253
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/ekvador.png",
      trisim: "Ekvador",
      enisim: "Ecuador",
      isim: "Ekvador",
      baskent: "Quito",
      kita: "Americas",
      url: "https://flagcdn.com/w320/ec.png",
      bilgi: false,
      bm: true,
      enlem: -2,
      boylam: -77.5,
      dosyaboyut: 5052
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/gurcistan.png",
      trisim: "Grcistan",
      enisim: "Georgia",
      isim: "Gurcistan",
      baskent: "Tbilisi",
      kita: "Asia",
      url: "https://flagcdn.com/w320/ge.png",
      bilgi: false,
      bm: true,
      enlem: 42,
      boylam: 43.5,
      dosyaboyut: 1046
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/malavi.png",
      trisim: "Malavi",
      enisim: "Malawi",
      isim: "Malavi",
      baskent: "Lilongwe",
      kita: "Africa",
      url: "https://flagcdn.com/w320/mw.png",
      bilgi: false,
      bm: true,
      enlem: -13.5,
      boylam: 34,
      dosyaboyut: 1467
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/irak.png",
      trisim: "Irak",
      enisim: "Iraq",
      isim: "Irak",
      baskent: "Baghdad",
      kita: "Asia",
      url: "https://flagcdn.com/w320/iq.png",
      bilgi: false,
      bm: true,
      enlem: 33,
      boylam: 44,
      dosyaboyut: 789
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/svalbardvejanmayen.png",
      trisim: "Svalbardvejanmayen",
      enisim: "Svalbardandjanmayen",
      isim: "Svalbardvejanmayen",
      baskent: "Longyearbyen",
      kita: "Europe",
      url: "https://flagcdn.com/w320/sj.png",
      bilgi: false,
      bm: false,
      enlem: 78,
      boylam: 20,
      dosyaboyut: 323
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/benin.png",
      trisim: "Benin",
      enisim: "Benin",
      isim: "Benin",
      baskent: "Portonovo",
      kita: "Africa",
      url: "https://flagcdn.com/w320/bj.png",
      bilgi: false,
      bm: true,
      enlem: 9.5,
      boylam: 2.25,
      dosyaboyut: 176
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/japonya.png",
      trisim: "Japonya",
      enisim: "Japan",
      isim: "Japonya",
      baskent: "Tokyo",
      kita: "Asia",
      url: "https://flagcdn.com/w320/jp.png",
      bilgi: false,
      bm: true,
      enlem: 36,
      boylam: 138,
      dosyaboyut: 932
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/dominikcumhuriyeti.png",
      trisim: "Dominikcumhuriyeti",
      enisim: "Dominicanrepublic",
      isim: "Dominikcumhuriyeti",
      baskent: "Santodomingo",
      kita: "Americas",
      url: "https://flagcdn.com/w320/do.png",
      bilgi: false,
      bm: true,
      enlem: 19,
      boylam: -70.67,
      dosyaboyut: 1658
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/katar.png",
      trisim: "Katar",
      enisim: "Qatar",
      isim: "Katar",
      baskent: "Doha",
      kita: "Asia",
      url: "https://flagcdn.com/w320/qa.png",
      bilgi: false,
      bm: true,
      enlem: 25.5,
      boylam: 51.25,
      dosyaboyut: 336
  ),
  Ulkeler(
      bayrak: "dosyalar/bayraklar/gabon.png",
      trisim: "Gabon",
      enisim: "Gabon",
      isim: "Gabon",
      baskent: "Libreville",
      kita: "Africa",
      url: "https://flagcdn.com/w320/ga.png",
      bilgi: false,
      bm: true,
      enlem: -1,
      boylam: 11.75,
      dosyaboyut: 161
  ),
];
