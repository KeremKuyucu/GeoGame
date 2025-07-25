import 'package:GeoGame/util.dart';
import 'package:http/http.dart' as http;

class Ulkeler {
  final String url;
  final String bayrak;
  final String enisim;
  final String isim;
  final String baskent;
  final String kita;
  final bool bm;
  final double enlem;
  final double boylam;
  Ulkeler({
    required this.bayrak, required this.enisim, required this.isim, required this.baskent, required this.kita,
    required this.url, required this.bm, required this.enlem, required this.boylam,
  });
  bool ks(String yapilantahmin) {
    return yapilantahmin == isim || yapilantahmin == enisim;
  }
}
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
class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _sebepController = TextEditingController();
    final TextEditingController _messageController = TextEditingController();

    Future<void> sendMessage(String sebep, String message) async {
      final url = Uri.parse('$apiserver/feedback');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sebep': sebep,
          'message': message,
          'isim': name,
          'uid': uid,
        }),
      );

      if (response.statusCode == 200) {
        print('Mesaj başarıyla gönderildi.');
      } else {
        print('Mesaj gönderilemedi.');
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                SizedBox(width: 10),
                Text(
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
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.report, color: Colors.blueAccent),
            title: Text(Yazi.get('hatabildir'), style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Yazi.get('hatabildir'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextField(_sebepController, Yazi.get('hatabaslik')),
                          SizedBox(height: 10),
                          _buildTextField(_messageController, Yazi.get('hatametin')),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  sendMessage(
                                    _sebepController.text,
                                    _messageController.text,
                                  );
                                  _sebepController.clear();
                                  _messageController.clear();
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Text('Gönder'),
                                ),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Text('İptal'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text(
              Yazi.get('sikayet'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          Divider(),
          _buildListTile(Icons.share, Color(0xFF5865F2), Yazi.get('uygpaylas'), () async {
            await Share.share(Yazi.get('davetpromt'));
          }),
          _buildListTile(Icons.person, Color(0xFF5865F2), Yazi.get('yapimcimetin'), () async {
            await EasyLauncher.url(url: 'https://keremkk.com.tr', mode: Mode.platformDefault);
          }),
          _buildListTile(Icons.public, Colors.red, Yazi.get('website'), () async {
            await EasyLauncher.url(url: 'https://keremkk.com.tr/geogame');
          }),
          _buildListTile(FontAwesomeIcons.github, Colors.black, Yazi.get('github'), () async {
            await EasyLauncher.url(url: 'https://github.com/KeremKuyucu/GeoGame');
          }),
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

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, Color iconColor, String title, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
class CustomNotification extends StatelessWidget {
  final String baslik;
  final String metin;

  CustomNotification({required this.baslik,required this.metin});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue, // Bildirimin rengini değiştirebilirsiniz
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                baslik,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                metin,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();  // Bildirimi kapat
                        },
                        child: Text(
                          Yazi.get('tamam'),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//     showDialog(
//       context: context,
//       builder: (context) {
//         return CustomNotification(baslik: baslikmetin,metin: icerikmetin);
//       },

bool amerikakitasi = true, asyakitasi = true, afrikakitasi = true, avrupakitasi = true, okyanusyakitasi = true, antartikakitasi = true, bmuyeligi = false, sadecebm= false, yazmamodu = true, backgroundMusicPlaying = false, darktema=true, isEnglish=false;
final List<String> diller = ['Türkçe','English'];
String diltercihi = '';
int mesafedogru=0, mesafeyanlis=0, bayrakdogru=0, bayrakyanlis=0, baskentdogru=0, baskentyanlis=0, mesafepuan=0, bayrakpuan=0, baskentpuan=0, toplampuan=0, selectedIndex = 0;
String name = "",profilurl= "https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363",uid = '', secilenDil='', apiserver = "https://geogame-api.keremkk.com.tr/api";
List<dynamic> users = [];
final List<Color> buttonColors = [
  Colors.green,
  Colors.yellow,
  Colors.blue,
  Colors.red
];
final List<bool> butontiklama = [
  true,true,true,true,true
];
final random = Random();

// Fonksiyonlar
Future<void> yeniulkesec() async {
  print("yeni ülke seçildi");
  butontiklama[0]=true;
  butontiklama[1]=true;
  butontiklama[2]=true;
  butontiklama[3]=true;
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
    if ((u.kita == "Americas" && amerikakitasi ||
            u.kita == "Asia" && asyakitasi ||
            u.kita == "Africa" && afrikakitasi ||
            u.kita == "Europe" && avrupakitasi ||
            u.kita == "Oceania" && okyanusyakitasi ||
            u.kita == "Antarctic" && antartikakitasi) &&
        (u.bm || bmuyeligi)) {
      count++;
    }
  }
  //print('Ülke Sayısı: $count');
  return count;
}
Future<void> readFromFile(Function updateState) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/geogame.json';
  final file = File(filePath);

  if (await file.exists()) {
    final contents = await file.readAsString();
    final jsonData = jsonDecode(contents);

    updateState(() {
      amerikakitasi = jsonData['amerikakitasi'] == true;
      asyakitasi = jsonData['asyakitasi'] == true;
      afrikakitasi = jsonData['afrikakitasi'] == true;
      avrupakitasi = jsonData['avrupakitasi'] == true;
      okyanusyakitasi = jsonData['okyanusyakitasi'] == true;
      antartikakitasi = jsonData['antartikakitasi'] == true;
      bmuyeligi = jsonData['bmuyeligi'] == true;
      yazmamodu = jsonData['yazmamodu'] == true;
      darktema = jsonData['darktema'] == true;

      name = jsonData['name'] ?? '';
      uid = jsonData['uid'] ?? '';
      profilurl = jsonData['profilurl'] ?? 'https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363';
      secilenDil = jsonData['secilenDil'] ?? 'Türkçe';

      toplampuan = jsonData['toplampuan'] ?? 0;
      mesafedogru = jsonData['mesafedogru'] ?? 0;
      mesafeyanlis = jsonData['mesafeyanlis'] ?? 0;
      bayrakdogru = jsonData['bayrakdogru'] ?? 0;
      bayrakyanlis = jsonData['bayrakyanlis'] ?? 0;
      baskentdogru = jsonData['baskentdogru'] ?? 0;
      baskentyanlis = jsonData['baskentyanlis'] ?? 0;
      mesafepuan = jsonData['mesafepuan'] ?? 0;
      bayrakpuan = jsonData['bayrakpuan'] ?? 0;
      baskentpuan = jsonData['baskentpuan'] ?? 0;
      print ("dosyadan okundu");
    });
  } else {
    debugPrint('Dosya bulunamadı: kurallar.json');
    writeToFile();
  }
}
Future<void> writeToFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/geogame.json';
  final file = File(filePath);
  toplampuan=bayrakpuan+baskentpuan+mesafepuan;
  final data = {
    'amerikakitasi': amerikakitasi,
    'asyakitasi': asyakitasi,
    'afrikakitasi': afrikakitasi,
    'avrupakitasi': avrupakitasi,
    'okyanusyakitasi': okyanusyakitasi,
    'antartikakitasi': antartikakitasi,
    'bmuyeligi': bmuyeligi,
    'yazmamodu': yazmamodu,
    'darktema': darktema,
    'name': name,
    'uid': uid,
    'profilurl': profilurl,
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
  print("dosyaya yazıldı");
}
Future<void> puanguncelle() async {
  try {
    final response = await http.get(
      Uri.parse('${apiserver}/get_leadboard'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      users = data['users'].map((user) {
        return {
          'name': user['name'] ?? '',
          'uid': user['uid'] ?? '',
          'profilurl': user['profilurl'] ??
              'https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363',
          'puan': int.parse(user['puan'] ?? "0"),
          'mesafepuan': int.tryParse(user['mesafepuan'] ?? '0') ?? 0,
          'baskentpuan': int.tryParse(user['baskentpuan'] ?? '0') ?? 0,
          'bayrakpuan': int.tryParse(user['bayrakpuan'] ?? '0') ?? 0,
          'mesafedogru': int.tryParse(user['mesafedogru'] ?? '0') ?? 0,
          'baskentdogru': int.tryParse(user['baskentdogru'] ?? '0') ?? 0,
          'bayrakdogru': int.tryParse(user['bayrakdogru'] ?? '0') ?? 0,
          'mesafeyanlis': int.tryParse(user['mesafeyanlis'] ?? '0') ?? 0,
          'baskentyanlis': int.tryParse(user['baskentyanlis'] ?? '0') ?? 0,
          'bayrakyanlis': int.tryParse(user['bayrakyanlis'] ?? '0') ?? 0,
        };
      }).toList();

      for (var user in users) {
        if (user['uid'] ==  uid) {
          debugPrint('uidler eşleşti');
          if (toplampuan < user['puan']) {
            debugPrint('puan daha düşük güncellendi');
            uid = user['uid'];
            name = user['name'];
            profilurl = user['profilurl'];
            toplampuan = user['puan'];
            mesafepuan = user['mesafepuan'];
            baskentpuan = user['baskentpuan'];
            bayrakpuan = user['bayrakpuan'];
            mesafedogru = user['mesafedogru'];
            baskentdogru = user['baskentdogru'];
            bayrakdogru = user['bayrakdogru'];
            mesafeyanlis = user['mesafeyanlis'];
            baskentyanlis = user['baskentyanlis'];
            bayrakyanlis = user['bayrakyanlis'];
            writeToFile();
          }
          break;
        }
      }

      print("Veri başarıyla güncellendi.");
    } else {
      throw Exception('Veri yüklenemedi.');
    }
  } catch (e) {
    print('Hata: $e');
  }
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
Future<void> postLeadboard() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String country = (await getCountry()).replaceAll('\n', '');

    final fullMessage = '{\n'
        '"mesaj": "Log Mesajı",\n'
        '"name": "$name",\n'
        '"uid": "$uid",\n'
        '"profilurl": "$profilurl",\n'
        '"surum": "$localVersion",\n'
        '"ulke": "$country",\n'
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
        '}';

    // Diğer mesajı gönder
    final targetUrl = '${apiserver}/post_leadboard';
    final response = await http.post(
      Uri.parse(targetUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': fullMessage,
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      debugPrint('Log başarıyla gönderildi!');
    } else {
     debugPrint('Log gönderilemedi: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Hata: $e');
  }
}
Future<void> postUlkeLog(String message) async {
  try {
    final targetUrl = '${apiserver}/ulkelog';
    final response = await http.post(
      Uri.parse(targetUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': message,
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      debugPrint('Ulke Log başarıyla gönderildi!');
    } else {
      debugPrint('Ulke Log gönderilemedi: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Hata: $e');
  }
}
// Listeler
Ulkeler gecici = Ulkeler(
  bayrak: '',
  enisim: '',
  isim: '',
  baskent: '',
  kita: '',
  url: '',
  bm: false,
  enlem: 0.0,
  boylam: 0.0,
);
Ulkeler kalici = Ulkeler(
  bayrak: '',
  enisim: '',
  isim: '',
  baskent: '',
  kita: '',
  url: '',
  bm: false,
  enlem: 0.0,
  boylam: 0.0,
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
    url: "https://flagcdn.com/w320/md.png",
    bayrak: "assets/bayraklar/moldova.png",
    enisim: "Moldova",
    isim: "Moldova",
    baskent: "Chisinau",
    kita: "Europe",
    bm: true,
    enlem: 47,
    boylam: 29,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/us.png",
    bayrak: "assets/bayraklar/amerikabirlesikdevletleri.png",
    enisim: "United states",
    isim: "Amerika birlesik devletleri",
    baskent: "Washingtondc",
    kita: "Americas",
    bm: true,
    enlem: 38,
    boylam: -97,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/yt.png",
    bayrak: "assets/bayraklar/mayotte.png",
    enisim: "Mayotte",
    isim: "Mayotte",
    baskent: "Mamoudzou",
    kita: "Africa",
    bm: false,
    enlem: -12.83,
    boylam: 45.17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/nr.png",
    bayrak: "assets/bayraklar/nauru.png",
    enisim: "Nauru",
    isim: "Nauru",
    baskent: "Yaren",
    kita: "Oceania",
    bm: true,
    enlem: -0.53,
    boylam: 166.92,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mz.png",
    bayrak: "assets/bayraklar/mozambik.png",
    enisim: "Mozambique",
    isim: "Mozambik",
    baskent: "Maputo",
    kita: "Africa",
    bm: true,
    enlem: -18.25,
    boylam: 35,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/br.png",
    bayrak: "assets/bayraklar/brezilya.png",
    enisim: "Brazil",
    isim: "Brezilya",
    baskent: "Brasÿlia",
    kita: "Americas",
    bm: true,
    enlem: -10,
    boylam: -55,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cv.png",
    bayrak: "assets/bayraklar/yesilburun.png",
    enisim: "Capeverde",
    isim: "Yesil burun",
    baskent: "Praia",
    kita: "Africa",
    bm: true,
    enlem: 16.54,
    boylam: -23.04,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gq.png",
    bayrak: "assets/bayraklar/ekvatorginesi.png",
    enisim: "Equatorial guinea",
    isim: "Ekvator ginesi",
    baskent: "Malabo",
    kita: "Africa",
    bm: true,
    enlem: 2,
    boylam: 10,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/al.png",
    bayrak: "assets/bayraklar/arnavutluk.png",
    enisim: "Albania",
    isim: "Arnavutluk",
    baskent: "Tirana",
    kita: "Europe",
    bm: true,
    enlem: 41,
    boylam: 20,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/vi.png",
    bayrak: "assets/bayraklar/abdvirjinadalari.png",
    enisim: "United states virgin islands",
    isim: "Abd virjin adalari",
    baskent: "Charlotteamalie",
    kita: "Americas",
    bm: false,
    enlem: 18.35,
    boylam: -64.93,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/nu.png",
    bayrak: "assets/bayraklar/niue.png",
    enisim: "Niue",
    isim: "Niue",
    baskent: "Alofi",
    kita: "Oceania",
    bm: false,
    enlem: -19.03,
    boylam: -169.87,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pw.png",
    bayrak: "assets/bayraklar/palau.png",
    enisim: "Palau",
    isim: "Palau",
    baskent: "Ngerulmud",
    kita: "Oceania",
    bm: true,
    enlem: 7.5,
    boylam: 134.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ng.png",
    bayrak: "assets/bayraklar/nijerya.png",
    enisim: "Nigeria",
    isim: "Nijerya",
    baskent: "Abuja",
    kita: "Africa",
    bm: true,
    enlem: 10,
    boylam: 8,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/vg.png",
    bayrak: "assets/bayraklar/virjinadalari.png",
    enisim: "Britishvirginislands",
    isim: "Virjin adalari",
    baskent: "Roadtown",
    kita: "Americas",
    bm: false,
    enlem: 18.43,
    boylam: -64.62,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gm.png",
    bayrak: "assets/bayraklar/gambiya.png",
    enisim: "Gambia",
    isim: "Gambiya",
    baskent: "Banjul",
    kita: "Africa",
    bm: true,
    enlem: 13.47,
    boylam: -16.57,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/so.png",
    bayrak: "assets/bayraklar/somali.png",
    enisim: "Somalia",
    isim: "Somali",
    baskent: "Mogadishu",
    kita: "Africa",
    bm: true,
    enlem: 10,
    boylam: 49,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ye.png",
    bayrak: "assets/bayraklar/yemen.png",
    enisim: "Yemen",
    isim: "Yemen",
    baskent: "Sanaa",
    kita: "Asia",
    bm: true,
    enlem: 15,
    boylam: 48,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/my.png",
    bayrak: "assets/bayraklar/malezya.png",
    enisim: "Malaysia",
    isim: "Malezya",
    baskent: "Kualalumpur",
    kita: "Asia",
    bm: true,
    enlem: 2.5,
    boylam: 112.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/dm.png",
    bayrak: "assets/bayraklar/dominika.png",
    enisim: "Dominica",
    isim: "Dominika",
    baskent: "Roseau",
    kita: "Americas",
    bm: true,
    enlem: 15.42,
    boylam: -61.33,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gb.png",
    bayrak: "assets/bayraklar/birlesikkrallik.png",
    enisim: "Unitedkingdom",
    isim: "Birlesikkrallik",
    baskent: "London",
    kita: "Europe",
    bm: true,
    enlem: 54,
    boylam: -2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mg.png",
    bayrak: "assets/bayraklar/madagaskar.png",
    enisim: "Madagascar",
    isim: "Madagaskar",
    baskent: "Antananarivo",
    kita: "Africa",
    bm: true,
    enlem: -20,
    boylam: 47,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/eh.png",
    bayrak: "assets/bayraklar/sahrademokratikarapcumhuriyeti.png",
    enisim: "Westernsahara",
    isim: "Sahrademokratikarapcumhuriyeti",
    baskent: "Elaaiun",
    kita: "Africa",
    bm: false,
    enlem: 24.5,
    boylam: -13,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cy.png",
    bayrak: "assets/bayraklar/kibris.png",
    enisim: "Cyprus",
    isim: "Kibris",
    baskent: "Nicosia",
    kita: "Europe",
    bm: true,
    enlem: 35,
    boylam: 33,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ag.png",
    bayrak: "assets/bayraklar/antiguavebarbuda.png",
    enisim: "Antiguaandbarbuda",
    isim: "Antiguavebarbuda",
    baskent: "Saintjohns",
    kita: "Americas",
    bm: true,
    enlem: 17.05,
    boylam: -61.8,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ie.png",
    bayrak: "assets/bayraklar/irlanda.png",
    enisim: "Ireland",
    isim: "Irlanda",
    baskent: "Dublin",
    kita: "Europe",
    bm: true,
    enlem: 53,
    boylam: -8,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/py.png",
    bayrak: "assets/bayraklar/paraguay.png",
    enisim: "Paraguay",
    isim: "Paraguay",
    baskent: "Asunci¾n",
    kita: "Americas",
    bm: true,
    enlem: -23,
    boylam: -58,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/lk.png",
    bayrak: "assets/bayraklar/srilanka.png",
    enisim: "Srilanka",
    isim: "Srilanka",
    baskent: "Srijayawardenepurakotte",
    kita: "Asia",
    bm: true,
    enlem: 7,
    boylam: 81,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/za.png",
    bayrak: "assets/bayraklar/guneyafrika.png",
    enisim: "Southafrica",
    isim: "Guneyafrika",
    baskent: "Pretoriabloemfonteincapetown",
    kita: "Africa",
    bm: true,
    enlem: -29,
    boylam: 24,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/kw.png",
    bayrak: "assets/bayraklar/kuveyt.png",
    enisim: "Kuwait",
    isim: "Kuveyt",
    baskent: "Kuwaitcity",
    kita: "Asia",
    bm: true,
    enlem: 29.5,
    boylam: 45.75,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/dz.png",
    bayrak: "assets/bayraklar/cezayir.png",
    enisim: "Algeria",
    isim: "Cezayir",
    baskent: "Algiers",
    kita: "Africa",
    bm: true,
    enlem: 28,
    boylam: 3,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/hr.png",
    bayrak: "assets/bayraklar/hirvatistan.png",
    enisim: "Croatia",
    isim: "Hirvatistan",
    baskent: "Zagreb",
    kita: "Europe",
    bm: true,
    enlem: 45.17,
    boylam: 15.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mq.png",
    bayrak: "assets/bayraklar/martinik.png",
    enisim: "Martinique",
    isim: "Martinik",
    baskent: "Fortdefrance",
    kita: "Americas",
    bm: false,
    enlem: 14.67,
    boylam: -61,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sl.png",
    bayrak: "assets/bayraklar/sierraleone.png",
    enisim: "Sierraleone",
    isim: "Sierraleone",
    baskent: "Freetown",
    kita: "Africa",
    bm: true,
    enlem: 8.5,
    boylam: -11.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mp.png",
    bayrak: "assets/bayraklar/kuzeymarianaadalari.png",
    enisim: "Northernmarianaislands",
    isim: "Kuzeymarianaadalari",
    baskent: "Saipan",
    kita: "Oceania",
    bm: false,
    enlem: 15.2,
    boylam: 145.75,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/rw.png",
    bayrak: "assets/bayraklar/ruanda.png",
    enisim: "Rwanda",
    isim: "Ruanda",
    baskent: "Kigali",
    kita: "Africa",
    bm: true,
    enlem: -2,
    boylam: 30,
  ),
  Ulkeler(
    url: "https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/suriye?v=1739643150915",
    bayrak: "assets/bayraklar/suriye.png",
    enisim: "Syria",
    isim: "Suriye",
    baskent: "Damascus",
    kita: "Asia",
    bm: true,
    enlem: 35,
    boylam: 38,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/vc.png",
    bayrak: "assets/bayraklar/saintvincentvegrenadinler.png",
    enisim: "Saintvincentandthegrenadines",
    isim: "Saintvincentvegrenadinler",
    baskent: "Kingstown",
    kita: "Americas",
    bm: true,
    enlem: 13.25,
    boylam: -61.2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/xk.png",
    bayrak: "assets/bayraklar/kosova.png",
    enisim: "Kosovo",
    isim: "Kosova",
    baskent: "Pristina",
    kita: "Europe",
    bm: false,
    enlem: 42.67,
    boylam: 21.17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/lc.png",
    bayrak: "assets/bayraklar/saintlucia.png",
    enisim: "Saintlucia",
    isim: "Saintlucia",
    baskent: "Castries",
    kita: "Americas",
    bm: true,
    enlem: 13.88,
    boylam: -60.97,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/hn.png",
    bayrak: "assets/bayraklar/honduras.png",
    enisim: "Honduras",
    isim: "Honduras",
    baskent: "Tegucigalpa",
    kita: "Americas",
    bm: true,
    enlem: 15,
    boylam: -86.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/jo.png",
    bayrak: "assets/bayraklar/urdun.png",
    enisim: "Jordan",
    isim: "Urdun",
    baskent: "Amman",
    kita: "Asia",
    bm: true,
    enlem: 31,
    boylam: 36,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tv.png",
    bayrak: "assets/bayraklar/tuvalu.png",
    enisim: "Tuvalu",
    isim: "Tuvalu",
    baskent: "Funafuti",
    kita: "Oceania",
    bm: true,
    enlem: -8,
    boylam: 178,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/np.png",
    bayrak: "assets/bayraklar/nepal.png",
    enisim: "Nepal",
    isim: "Nepal",
    baskent: "Kathmandu",
    kita: "Asia",
    bm: true,
    enlem: 28,
    boylam: 84,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/lr.png",
    bayrak: "assets/bayraklar/liberya.png",
    enisim: "Liberia",
    isim: "Liberya",
    baskent: "Monrovia",
    kita: "Africa",
    bm: true,
    enlem: 6.5,
    boylam: -9.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/hm.png",
    bayrak: "assets/bayraklar/heardadasivemcdonaldadalari.png",
    enisim: "Heardislandandmcdonaldislands",
    isim: "Heardadasivemcdonaldadalari",
    baskent: "",
    kita: "Antarctic",
    bm: false,
    enlem: 53.08,
    boylam: 73.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/at.png",
    bayrak: "assets/bayraklar/avusturya.png",
    enisim: "Austria",
    isim: "Avusturya",
    baskent: "Vienna",
    kita: "Europe",
    bm: true,
    enlem: 47.33,
    boylam: 13.33,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gg.png",
    bayrak: "assets/bayraklar/guernsey.png",
    enisim: "Guernsey",
    isim: "Guernsey",
    baskent: "Stpeterport",
    kita: "Europe",
    bm: false,
    enlem: 49.47,
    boylam: -2.58,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cf.png",
    bayrak: "assets/bayraklar/ortaafrikacumhuriyeti.png",
    enisim: "Centralafricanrepublic",
    isim: "Ortaafrikacumhuriyeti",
    baskent: "Bangui",
    kita: "Africa",
    bm: true,
    enlem: 7,
    boylam: 21,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mr.png",
    bayrak: "assets/bayraklar/moritanya.png",
    enisim: "Mauritania",
    isim: "Moritanya",
    baskent: "Nouakchott",
    kita: "Africa",
    bm: true,
    enlem: 20,
    boylam: -12,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/dj.png",
    bayrak: "assets/bayraklar/cibuti.png",
    enisim: "Djibouti",
    isim: "Cibuti",
    baskent: "Djibouti",
    kita: "Africa",
    bm: true,
    enlem: 11.5,
    boylam: 43,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/fj.png",
    bayrak: "assets/bayraklar/fiji.png",
    enisim: "Fiji",
    isim: "Fiji",
    baskent: "Suva",
    kita: "Oceania",
    bm: true,
    enlem: 17.71,
    boylam: 178.06,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/no.png",
    bayrak: "assets/bayraklar/norvec.png",
    enisim: "Norway",
    isim: "Norvec",
    baskent: "Oslo",
    kita: "Europe",
    bm: true,
    enlem: 62,
    boylam: 10,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/lv.png",
    bayrak: "assets/bayraklar/letonya.png",
    enisim: "Latvia",
    isim: "Letonya",
    baskent: "Riga",
    kita: "Europe",
    bm: true,
    enlem: 57,
    boylam: 25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/fk.png",
    bayrak: "assets/bayraklar/falklandmalvinaadalari.png",
    enisim: "Falklandislands",
    isim: "Falklandmalvinaadalari",
    baskent: "Stanley",
    kita: "Americas",
    bm: false,
    enlem: -51.75,
    boylam: -59,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/kz.png",
    bayrak: "assets/bayraklar/kazakistan.png",
    enisim: "Kazakhstan",
    isim: "Kazakistan",
    baskent: "Nursultan",
    kita: "Asia",
    bm: true,
    enlem: 48.02,
    boylam: 66.92,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ax.png",
    bayrak: "assets/bayraklar/aland.png",
    enisim: "Alandislands",
    isim: "Aland",
    baskent: "Mariehamn",
    kita: "Europe",
    bm: false,
    enlem: 60.12,
    boylam: 19.9,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tm.png",
    bayrak: "assets/bayraklar/turkmenistan.png",
    enisim: "Turkmenistan",
    isim: "Turkmenistan",
    baskent: "Ashgabat",
    kita: "Asia",
    bm: true,
    enlem: 40,
    boylam: 60,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cc.png",
    bayrak: "assets/bayraklar/cocoskeelingadalari.png",
    enisim: "Cocoskeelingislands",
    isim: "Cocoskeelingadalari",
    baskent: "Westisland",
    kita: "Oceania",
    bm: false,
    enlem: 12.16,
    boylam: 96.87,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bg.png",
    bayrak: "assets/bayraklar/bulgaristan.png",
    enisim: "Bulgaria",
    isim: "Bulgaristan",
    baskent: "Sofia",
    kita: "Europe",
    bm: true,
    enlem: 43,
    boylam: 25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tk.png",
    bayrak: "assets/bayraklar/tokelau.png",
    enisim: "Tokelau",
    isim: "Tokelau",
    baskent: "Fakaofo",
    kita: "Oceania",
    bm: false,
    enlem: -9,
    boylam: -172,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/nc.png",
    bayrak: "assets/bayraklar/yenikaledonya.png",
    enisim: "Newcaledonia",
    isim: "Yenikaledonya",
    baskent: "NoumÚa",
    kita: "Oceania",
    bm: false,
    enlem: -21.5,
    boylam: 165.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bb.png",
    bayrak: "assets/bayraklar/barbados.png",
    enisim: "Barbados",
    isim: "Barbados",
    baskent: "Bridgetown",
    kita: "Americas",
    bm: true,
    enlem: 13.17,
    boylam: -59.53,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/st.png",
    bayrak: "assets/bayraklar/saotomeandprincipe.png",
    enisim: "Saotomeandprincipe",
    isim: "Saotomeandprincipe",
    baskent: "Saotome",
    kita: "Africa",
    bm: true,
    enlem: 1,
    boylam: 7,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/aq.png",
    bayrak: "assets/bayraklar/antarktika.png",
    enisim: "Antarctica",
    isim: "Antarktika",
    baskent: "",
    kita: "Antarctic",
    bm: false,
    enlem: -90,
    boylam: 0,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bn.png",
    bayrak: "assets/bayraklar/brunei.png",
    enisim: "Brunei",
    isim: "Brunei",
    baskent: "Bandarseribegawan",
    kita: "Asia",
    bm: true,
    enlem: 4.5,
    boylam: 114.67,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bt.png",
    bayrak: "assets/bayraklar/butan.png",
    enisim: "Bhutan",
    isim: "Butan",
    baskent: "Thimphu",
    kita: "Asia",
    bm: true,
    enlem: 27.5,
    boylam: 90.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cm.png",
    bayrak: "assets/bayraklar/kamerun.png",
    enisim: "Cameroon",
    isim: "Kamerun",
    baskent: "YaoundÚ",
    kita: "Africa",
    bm: true,
    enlem: 6,
    boylam: 12,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ar.png",
    bayrak: "assets/bayraklar/arjantin.png",
    enisim: "Argentina",
    isim: "Arjantin",
    baskent: "Buenosaires",
    kita: "Americas",
    bm: true,
    enlem: -34,
    boylam: -64,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/az.png",
    bayrak: "assets/bayraklar/azerbaycan.png",
    enisim: "Azerbaijan",
    isim: "Azerbaycan",
    baskent: "Baku",
    kita: "Asia",
    bm: true,
    enlem: 40.5,
    boylam: 47.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mx.png",
    bayrak: "assets/bayraklar/meksika.png",
    enisim: "Mexico",
    isim: "Meksika",
    baskent: "Mexicocity",
    kita: "Americas",
    bm: true,
    enlem: 23,
    boylam: -102,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ma.png",
    bayrak: "assets/bayraklar/fas.png",
    enisim: "Morocco",
    isim: "Fas",
    baskent: "Rabat",
    kita: "Africa",
    bm: true,
    enlem: 32,
    boylam: -5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gt.png",
    bayrak: "assets/bayraklar/guatemala.png",
    enisim: "Guatemala",
    isim: "Guatemala",
    baskent: "Guatemalacity",
    kita: "Americas",
    bm: true,
    enlem: 15.5,
    boylam: -90.25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ke.png",
    bayrak: "assets/bayraklar/kenya.png",
    enisim: "Kenya",
    isim: "Kenya",
    baskent: "Nairobi",
    kita: "Africa",
    bm: true,
    enlem: 1,
    boylam: 38,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mt.png",
    bayrak: "assets/bayraklar/malta.png",
    enisim: "Malta",
    isim: "Malta",
    baskent: "Valletta",
    kita: "Europe",
    bm: true,
    enlem: 35.94,
    boylam: 14.38,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cz.png",
    bayrak: "assets/bayraklar/cekya.png",
    enisim: "Czechia",
    isim: "Cekya",
    baskent: "Prague",
    kita: "Europe",
    bm: true,
    enlem: 49.75,
    boylam: 15.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gi.png",
    bayrak: "assets/bayraklar/cebelitarik.png",
    enisim: "Gibraltar",
    isim: "Cebelitarik",
    baskent: "Gibraltar",
    kita: "Europe",
    bm: false,
    enlem: 36.13,
    boylam: -5.35,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/aw.png",
    bayrak: "assets/bayraklar/aruba.png",
    enisim: "Aruba",
    isim: "Aruba",
    baskent: "Oranjestad",
    kita: "Americas",
    bm: false,
    enlem: 12.5,
    boylam: -69.97,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bl.png",
    bayrak: "assets/bayraklar/saintbarthelemy.png",
    enisim: "Saintbarthelemy",
    isim: "Saintbarthelemy",
    baskent: "Gustavia",
    kita: "Americas",
    bm: false,
    enlem: 18.5,
    boylam: -63.42,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mc.png",
    bayrak: "assets/bayraklar/monako.png",
    enisim: "Monaco",
    isim: "Monako",
    baskent: "Monaco",
    kita: "Europe",
    bm: true,
    enlem: 43.73,
    boylam: 7.4,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ae.png",
    bayrak: "assets/bayraklar/birlesikarapemirlikleri.png",
    enisim: "Unitedarabemirates",
    isim: "Birlesikarapemirlikleri",
    baskent: "Abudhabi",
    kita: "Asia",
    bm: true,
    enlem: 24,
    boylam: 54,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ss.png",
    bayrak: "assets/bayraklar/guneysudan.png",
    enisim: "Southsudan",
    isim: "Guneysudan",
    baskent: "Juba",
    kita: "Africa",
    bm: true,
    enlem: 7,
    boylam: 30,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pr.png",
    bayrak: "assets/bayraklar/portoriko.png",
    enisim: "Puertorico",
    isim: "Portoriko",
    baskent: "Sanjuan",
    kita: "Americas",
    bm: false,
    enlem: 18.25,
    boylam: -66.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sv.png",
    bayrak: "assets/bayraklar/elsalvador.png",
    enisim: "Elsalvador",
    isim: "Elsalvador",
    baskent: "Sansalvador",
    kita: "Americas",
    bm: true,
    enlem: 13.83,
    boylam: -88.92,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/fr.png",
    bayrak: "assets/bayraklar/fransa.png",
    enisim: "France",
    isim: "Fransa",
    baskent: "Paris",
    kita: "Europe",
    bm: true,
    enlem: 46,
    boylam: 2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ne.png",
    bayrak: "assets/bayraklar/nijer.png",
    enisim: "Niger",
    isim: "Nijer",
    baskent: "Niamey",
    kita: "Africa",
    bm: true,
    enlem: 16,
    boylam: 8,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ci.png",
    bayrak: "assets/bayraklar/fildisisahili.png",
    enisim: "Ivorycoast",
    isim: "Fildisisahili",
    baskent: "Yamoussoukro",
    kita: "Africa",
    bm: true,
    enlem: 8,
    boylam: -5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gs.png",
    bayrak: "assets/bayraklar/guneygeorgiaveguneysandwichadalari.png",
    enisim: "Southgeorgia",
    isim: "Guneygeorgiaveguneysandwichadalari",
    baskent: "Kingedwardpoint",
    kita: "Antarctic",
    bm: false,
    enlem: -54.5,
    boylam: -37,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bw.png",
    bayrak: "assets/bayraklar/botsvana.png",
    enisim: "Botswana",
    isim: "Botsvana",
    baskent: "Gaborone",
    kita: "Africa",
    bm: true,
    enlem: -22,
    boylam: 24,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/io.png",
    bayrak: "assets/bayraklar/britanyahintokyanusutopraklari.png",
    enisim: "Britishindianoceanterritory",
    isim: "Britanyahintokyanusutopraklari",
    baskent: "Diegogarcia",
    kita: "Africa",
    bm: false,
    enlem: -6,
    boylam: 71.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/uz.png",
    bayrak: "assets/bayraklar/ozbekistan.png",
    enisim: "Uzbekistan",
    isim: "Ozbekistan",
    baskent: "Tashkent",
    kita: "Asia",
    bm: true,
    enlem: 41,
    boylam: 64,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tn.png",
    bayrak: "assets/bayraklar/tunus.png",
    enisim: "Tunisia",
    isim: "Tunus",
    baskent: "Tunis",
    kita: "Africa",
    bm: true,
    enlem: 34,
    boylam: 9,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/hk.png",
    bayrak: "assets/bayraklar/hongkong.png",
    enisim: "Hongkong",
    isim: "Hongkong",
    baskent: "Cityofvictoria",
    kita: "Asia",
    bm: false,
    enlem: 22.27,
    boylam: 114.19,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mk.png",
    bayrak: "assets/bayraklar/kuzeymakedonya.png",
    enisim: "Northmacedonia",
    isim: "Kuzeymakedonya",
    baskent: "Skopje",
    kita: "Europe",
    bm: true,
    enlem: 41.83,
    boylam: 22,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sr.png",
    bayrak: "assets/bayraklar/surinam.png",
    enisim: "Suriname",
    isim: "Surinam",
    baskent: "Paramaribo",
    kita: "Americas",
    bm: true,
    enlem: 4,
    boylam: -56,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/be.png",
    bayrak: "assets/bayraklar/belcika.png",
    enisim: "Belgium",
    isim: "Belcika",
    baskent: "Brussels",
    kita: "Europe",
    bm: true,
    enlem: 50.83,
    boylam: 4,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/as.png",
    bayrak: "assets/bayraklar/amerikansamoasi.png",
    enisim: "Americansamoa",
    isim: "Amerikansamoasi",
    baskent: "Pagopago",
    kita: "Oceania",
    bm: false,
    enlem: -14.33,
    boylam: -170,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sb.png",
    bayrak: "assets/bayraklar/solomonadalari.png",
    enisim: "Solomonislands",
    isim: "Solomonadalari",
    baskent: "Honiara",
    kita: "Oceania",
    bm: true,
    enlem: -8,
    boylam: 159,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ua.png",
    bayrak: "assets/bayraklar/ukrayna.png",
    enisim: "Ukraine",
    isim: "Ukrayna",
    baskent: "Kyiv",
    kita: "Europe",
    bm: true,
    enlem: 49,
    boylam: 32,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/fi.png",
    bayrak: "assets/bayraklar/finlandiya.png",
    enisim: "Finland",
    isim: "Finlandiya",
    baskent: "Helsinki",
    kita: "Europe",
    bm: true,
    enlem: 64,
    boylam: 26,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bf.png",
    bayrak: "assets/bayraklar/burkinafaso.png",
    enisim: "Burkinafaso",
    isim: "Burkinafaso",
    baskent: "Ouagadougou",
    kita: "Africa",
    bm: true,
    enlem: 13,
    boylam: -2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ba.png",
    bayrak: "assets/bayraklar/bosnahersek.png",
    enisim: "Bosniaandherzegovina",
    isim: "Bosnahersek",
    baskent: "Sarajevo",
    kita: "Europe",
    bm: true,
    enlem: 44,
    boylam: 18,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ir.png",
    bayrak: "assets/bayraklar/iran.png",
    enisim: "Iran",
    isim: "Iran",
    baskent: "Tehran",
    kita: "Asia",
    bm: true,
    enlem: 32,
    boylam: 53,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cu.png",
    bayrak: "assets/bayraklar/kuba.png",
    enisim: "Cuba",
    isim: "Kuba",
    baskent: "Havana",
    kita: "Americas",
    bm: true,
    enlem: 21.5,
    boylam: -80,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/er.png",
    bayrak: "assets/bayraklar/eritre.png",
    enisim: "Eritrea",
    isim: "Eritre",
    baskent: "Asmara",
    kita: "Africa",
    bm: true,
    enlem: 15,
    boylam: 39,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sk.png",
    bayrak: "assets/bayraklar/slovakya.png",
    enisim: "Slovakia",
    isim: "Slovakya",
    baskent: "Bratislava",
    kita: "Europe",
    bm: true,
    enlem: 48.67,
    boylam: 19.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/lt.png",
    bayrak: "assets/bayraklar/litvanya.png",
    enisim: "Lithuania",
    isim: "Litvanya",
    baskent: "Vilnius",
    kita: "Europe",
    bm: true,
    enlem: 56,
    boylam: 24,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mf.png",
    bayrak: "assets/bayraklar/saintmartin.png",
    enisim: "Saintmartin",
    isim: "Saintmartin",
    baskent: "Marigot",
    kita: "Americas",
    bm: false,
    enlem: 18.07,
    boylam: 63.05,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pn.png",
    bayrak: "assets/bayraklar/pitcairnadalari.png",
    enisim: "Pitcairnislands",
    isim: "Pitcairnadalari",
    baskent: "Adamstown",
    kita: "Oceania",
    bm: false,
    enlem: -25.07,
    boylam: -130.1,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gw.png",
    bayrak: "assets/bayraklar/ginebissau.png",
    enisim: "Guineabissau",
    isim: "Ginebissau",
    baskent: "Bissau",
    kita: "Africa",
    bm: false,
    enlem: 12,
    boylam: -15,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ms.png",
    bayrak: "assets/bayraklar/montserrat.png",
    enisim: "Montserrat",
    isim: "Montserrat",
    baskent: "Plymouth",
    kita: "Americas",
    bm: false,
    enlem: 16.75,
    boylam: -62.2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tr.png",
    bayrak: "assets/bayraklar/turkiye.png",
    enisim: "Turkey",
    isim: "Turkiye",
    baskent: "Ankara",
    kita: "Asia",
    bm: true,
    enlem: 39,
    boylam: 35,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ph.png",
    bayrak: "assets/bayraklar/filipinler.png",
    enisim: "Philippines",
    isim: "Filipinler",
    baskent: "Manila",
    kita: "Asia",
    bm: true,
    enlem: 13,
    boylam: 122,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/vu.png",
    bayrak: "assets/bayraklar/vanuatu.png",
    enisim: "Vanuatu",
    isim: "Vanuatu",
    baskent: "Portvila",
    kita: "Oceania",
    bm: true,
    enlem: -16,
    boylam: 167,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bo.png",
    bayrak: "assets/bayraklar/bolivya.png",
    enisim: "Bolivia",
    isim: "Bolivya",
    baskent: "Sucre",
    kita: "Americas",
    bm: true,
    enlem: -17,
    boylam: -65,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/kn.png",
    bayrak: "assets/bayraklar/saintkittsvenevis.png",
    enisim: "Saintkittsandnevis",
    isim: "Saintkittsvenevis",
    baskent: "Basseterre",
    kita: "Americas",
    bm: true,
    enlem: 17.33,
    boylam: -62.75,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ro.png",
    bayrak: "assets/bayraklar/romanya.png",
    enisim: "Romania",
    isim: "Romanya",
    baskent: "Bucharest",
    kita: "Europe",
    bm: true,
    enlem: 46,
    boylam: 25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/kh.png",
    bayrak: "assets/bayraklar/kambocya.png",
    enisim: "Cambodia",
    isim: "Kambocya",
    baskent: "Phnompenh",
    kita: "Asia",
    bm: true,
    enlem: 13,
    boylam: 105,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/zw.png",
    bayrak: "assets/bayraklar/zimbabve.png",
    enisim: "Zimbabwe",
    isim: "Zimbabve",
    baskent: "Harare",
    kita: "Africa",
    bm: true,
    enlem: -20,
    boylam: 30,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/je.png",
    bayrak: "assets/bayraklar/jersey.png",
    enisim: "Jersey",
    isim: "Jersey",
    baskent: "Sainthelier",
    kita: "Europe",
    bm: false,
    enlem: 49.25,
    boylam: -2.17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/kg.png",
    bayrak: "assets/bayraklar/kirgizistan.png",
    enisim: "Kyrgyzstan",
    isim: "Kirgizistan",
    baskent: "Bishkek",
    kita: "Asia",
    bm: true,
    enlem: 41,
    boylam: 75,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bq.png",
    bayrak: "assets/bayraklar/karayiphollandasi.png",
    enisim: "Caribbeannetherlands",
    isim: "Karayiphollandasi",
    baskent: "Kralendijk",
    kita: "Americas",
    bm: false,
    enlem: 12.18,
    boylam: -68.25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gy.png",
    bayrak: "assets/bayraklar/guyana.png",
    enisim: "Guyana",
    isim: "Guyana",
    baskent: "Georgetown",
    kita: "Americas",
    bm: true,
    enlem: 5,
    boylam: -59,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/um.png",
    bayrak: "assets/bayraklar/amerikabirlesikdevletlerikucukdisadalari.png",
    enisim: "Unitedstatesminoroutlyingislands",
    isim: "Amerikabirlesikdevletlerikucukdisadalari",
    baskent: "Washingtondc",
    kita: "Americas",
    bm: false,
    enlem: 19.3,
    boylam: 166.63,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/am.png",
    bayrak: "assets/bayraklar/ermenistan.png",
    enisim: "Armenia",
    isim: "Ermenistan",
    baskent: "Yerevan",
    kita: "Asia",
    bm: true,
    enlem: 40,
    boylam: 45,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/lb.png",
    bayrak: "assets/bayraklar/lubnan.png",
    enisim: "Lebanon",
    isim: "Lubnan",
    baskent: "Beirut",
    kita: "Asia",
    bm: true,
    enlem: 33.83,
    boylam: 35.83,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/me.png",
    bayrak: "assets/bayraklar/karadag.png",
    enisim: "Montenegro",
    isim: "Karadag",
    baskent: "Podgorica",
    kita: "Europe",
    bm: true,
    enlem: 42.5,
    boylam: 19.3,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gl.png",
    bayrak: "assets/bayraklar/gronland.png",
    enisim: "Greenland",
    isim: "Gronland",
    baskent: "Nuuk",
    kita: "Americas",
    bm: false,
    enlem: 72,
    boylam: -40,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pg.png",
    bayrak: "assets/bayraklar/papuayenigine.png",
    enisim: "Papuanewguinea",
    isim: "Papuayenigine",
    baskent: "Portmoresby",
    kita: "Oceania",
    bm: true,
    enlem: -6,
    boylam: 147,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/zm.png",
    bayrak: "assets/bayraklar/zambiya.png",
    enisim: "Zambia",
    isim: "Zambiya",
    baskent: "Lusaka",
    kita: "Africa",
    bm: true,
    enlem: -15,
    boylam: 30,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tt.png",
    bayrak: "assets/bayraklar/trinidadvetobago.png",
    enisim: "Trinidadandtobago",
    isim: "Trinidadvetobago",
    baskent: "Portofspain",
    kita: "Americas",
    bm: true,
    enlem: 10.69,
    boylam: -61.22,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tf.png",
    bayrak: "assets/bayraklar/fransizguneyveantarktikatopraklari.png",
    enisim: "Frenchsouthernandantarcticlands",
    isim: "Fransizguneyveantarktikatopraklari",
    baskent: "Portauxfranais",
    kita: "Antarctic",
    bm: false,
    enlem: -49.25,
    boylam: 69.17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pe.png",
    bayrak: "assets/bayraklar/peru.png",
    enisim: "Peru",
    isim: "Peru",
    baskent: "Lima",
    kita: "Americas",
    bm: true,
    enlem: -10,
    boylam: -76,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/se.png",
    bayrak: "assets/bayraklar/isvec.png",
    enisim: "Sweden",
    isim: "Isvec",
    baskent: "Stockholm",
    kita: "Europe",
    bm: true,
    enlem: 62,
    boylam: 15,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sd.png",
    bayrak: "assets/bayraklar/sudan.png",
    enisim: "Sudan",
    isim: "Sudan",
    baskent: "Khartoum",
    kita: "Africa",
    bm: true,
    enlem: 15,
    boylam: 30,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pm.png",
    bayrak: "assets/bayraklar/saintpierrevemiquelon.png",
    enisim: "Saintpierreandmiquelon",
    isim: "Saintpierrevemiquelon",
    baskent: "Saintpierre",
    kita: "Americas",
    bm: false,
    enlem: 46.83,
    boylam: -56.33,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/om.png",
    bayrak: "assets/bayraklar/umman.png",
    enisim: "Oman",
    isim: "Umman",
    baskent: "Muscat",
    kita: "Asia",
    bm: true,
    enlem: 21,
    boylam: 57,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/in.png",
    bayrak: "assets/bayraklar/hindistan.png",
    enisim: "India",
    isim: "Hindistan",
    baskent: "Newdelhi",
    kita: "Asia",
    bm: true,
    enlem: 20,
    boylam: 77,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tw.png",
    bayrak: "assets/bayraklar/tayvan.png",
    enisim: "Taiwan",
    isim: "Tayvan",
    baskent: "Taipei",
    kita: "Asia",
    bm: false,
    enlem: 23.5,
    boylam: 121,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mn.png",
    bayrak: "assets/bayraklar/mogolistan.png",
    enisim: "Mongolia",
    isim: "Mogolistan",
    baskent: "Ulanbator",
    kita: "Asia",
    bm: true,
    enlem: 46,
    boylam: 105,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sn.png",
    bayrak: "assets/bayraklar/senegal.png",
    enisim: "Senegal",
    isim: "Senegal",
    baskent: "Dakar",
    kita: "Africa",
    bm: true,
    enlem: 14,
    boylam: -14,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tz.png",
    bayrak: "assets/bayraklar/tanzanya.png",
    enisim: "Tanzania",
    isim: "Tanzanya",
    baskent: "Dodoma",
    kita: "Africa",
    bm: true,
    enlem: -6,
    boylam: 35,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ca.png",
    bayrak: "assets/bayraklar/kanada.png",
    enisim: "Canada",
    isim: "Kanada",
    baskent: "Ottawa",
    kita: "Americas",
    bm: true,
    enlem: 60,
    boylam: -95,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cr.png",
    bayrak: "assets/bayraklar/kostarika.png",
    enisim: "Costarica",
    isim: "Kostarika",
    baskent: "SanjosÚ",
    kita: "Americas",
    bm: true,
    enlem: 10,
    boylam: -84,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cn.png",
    bayrak: "assets/bayraklar/cin.png",
    enisim: "China",
    isim: "Cin",
    baskent: "Beijing",
    kita: "Asia",
    bm: true,
    enlem: 35,
    boylam: 105,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/co.png",
    bayrak: "assets/bayraklar/kolombiya.png",
    enisim: "Colombia",
    isim: "Kolombiya",
    baskent: "Bogotß",
    kita: "Americas",
    bm: true,
    enlem: 4,
    boylam: -72,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mm.png",
    bayrak: "assets/bayraklar/myanmar.png",
    enisim: "Myanmar",
    isim: "Myanmar",
    baskent: "Naypyidaw",
    kita: "Asia",
    bm: true,
    enlem: 22,
    boylam: 98,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ru.png",
    bayrak: "assets/bayraklar/rusya.png",
    enisim: "Russia",
    isim: "Rusya",
    baskent: "Moscow",
    kita: "Europe",
    bm: true,
    enlem: 60,
    boylam: 100,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/kp.png",
    bayrak: "assets/bayraklar/kuzeykore.png",
    enisim: "Northkorea",
    isim: "Kuzeykore",
    baskent: "Pyongyang",
    kita: "Asia",
    bm: true,
    enlem: 40,
    boylam: 127,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ky.png",
    bayrak: "assets/bayraklar/caymanadalari.png",
    enisim: "Caymanislands",
    isim: "Caymanadalari",
    baskent: "Georgetown",
    kita: "Americas",
    bm: false,
    enlem: 19.31,
    boylam: -81.25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bv.png",
    bayrak: "assets/bayraklar/bouvetadasi.png",
    enisim: "Bouvetisland",
    isim: "Bouvetadasi",
    baskent: "",
    kita: "Antarctic",
    bm: false,
    enlem: 54.42,
    boylam: 3.35,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/by.png",
    bayrak: "assets/bayraklar/belarus.png",
    enisim: "Belarus",
    isim: "Belarus",
    baskent: "Minsk",
    kita: "Europe",
    bm: true,
    enlem: 53,
    boylam: 28,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pt.png",
    bayrak: "assets/bayraklar/portekiz.png",
    enisim: "Portugal",
    isim: "Portekiz",
    baskent: "Lisbon",
    kita: "Europe",
    bm: true,
    enlem: 39.5,
    boylam: -8,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sz.png",
    bayrak: "assets/bayraklar/esvatini.png",
    enisim: "Eswatini",
    isim: "Esvatini",
    baskent: "Mbabane",
    kita: "Africa",
    bm: true,
    enlem: -26.5,
    boylam: 31.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pl.png",
    bayrak: "assets/bayraklar/polonya.png",
    enisim: "Poland",
    isim: "Polonya",
    baskent: "Warsaw",
    kita: "Europe",
    bm: true,
    enlem: 52,
    boylam: 20,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ch.png",
    bayrak: "assets/bayraklar/isvicre.png",
    enisim: "Switzerland",
    isim: "Isvicre",
    baskent: "Bern",
    kita: "Europe",
    bm: true,
    enlem: 47,
    boylam: 8,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cg.png",
    bayrak: "assets/bayraklar/kongocumhuriyeti.png",
    enisim: "Republicofthecongo",
    isim: "Kongocumhuriyeti",
    baskent: "Brazzaville",
    kita: "Africa",
    bm: true,
    enlem: -1,
    boylam: 15,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ve.png",
    bayrak: "assets/bayraklar/venezuela.png",
    enisim: "Venezuela",
    isim: "Venezuela",
    baskent: "Caracas",
    kita: "Americas",
    bm: true,
    enlem: 8,
    boylam: -66,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pa.png",
    bayrak: "assets/bayraklar/panama.png",
    enisim: "Panama",
    isim: "Panama",
    baskent: "Panamacity",
    kita: "Americas",
    bm: true,
    enlem: 9,
    boylam: -80,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/nl.png",
    bayrak: "assets/bayraklar/hollanda.png",
    enisim: "Netherlands",
    isim: "Hollanda",
    baskent: "Amsterdam",
    kita: "Europe",
    bm: true,
    enlem: 52.5,
    boylam: 5.75,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ws.png",
    bayrak: "assets/bayraklar/bagimsizsamoadevleti.png",
    enisim: "Samoa",
    isim: "Bagimsizsamoadevleti",
    baskent: "Apia",
    kita: "Oceania",
    bm: true,
    enlem: -13.58,
    boylam: -172.33,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/dk.png",
    bayrak: "assets/bayraklar/danimarka.png",
    enisim: "Denmark",
    isim: "Danimarka",
    baskent: "Copenhagen",
    kita: "Europe",
    bm: true,
    enlem: 56,
    boylam: 10,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/lu.png",
    bayrak: "assets/bayraklar/luksemburg.png",
    enisim: "Luxembourg",
    isim: "Luksemburg",
    baskent: "Luxembourg",
    kita: "Europe",
    bm: true,
    enlem: 49.75,
    boylam: 6.17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/fo.png",
    bayrak: "assets/bayraklar/faroeadalari.png",
    enisim: "Faroeislands",
    isim: "Faroeadalari",
    baskent: "T¾rshavn",
    kita: "Europe",
    bm: false,
    enlem: 62,
    boylam: -7,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/si.png",
    bayrak: "assets/bayraklar/slovenya.png",
    enisim: "Slovenia",
    isim: "Slovenya",
    baskent: "Ljubljana",
    kita: "Europe",
    bm: true,
    enlem: 46.12,
    boylam: 14.82,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tg.png",
    bayrak: "assets/bayraklar/togo.png",
    enisim: "Togo",
    isim: "Togo",
    baskent: "LomÚ",
    kita: "Africa",
    bm: true,
    enlem: 8,
    boylam: 1.17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/th.png",
    bayrak: "assets/bayraklar/tayland.png",
    enisim: "Thailand",
    isim: "Tayland",
    baskent: "Bangkok",
    kita: "Asia",
    bm: true,
    enlem: 15,
    boylam: 100,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/wf.png",
    bayrak: "assets/bayraklar/wallisvefutunaadalaribolgesi.png",
    enisim: "Wallisandfutuna",
    isim: "Wallisvefutunaadalaribolgesi",
    baskent: "Matautu",
    kita: "Oceania",
    bm: false,
    enlem: -13.3,
    boylam: -176.2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bs.png",
    bayrak: "assets/bayraklar/bahamalar.png",
    enisim: "Bahamas",
    isim: "Bahamalar",
    baskent: "Nassau",
    kita: "Americas",
    bm: true,
    enlem: 25.03,
    boylam: -77.4,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/to.png",
    bayrak: "assets/bayraklar/tonga.png",
    enisim: "Tonga",
    isim: "Tonga",
    baskent: "Nukualofa",
    kita: "Oceania",
    bm: true,
    enlem: -20,
    boylam: -175,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gr.png",
    bayrak: "assets/bayraklar/yunanistan.png",
    enisim: "Greece",
    isim: "Yunanistan",
    baskent: "Athens",
    kita: "Europe",
    bm: true,
    enlem: 39,
    boylam: 22,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sm.png",
    bayrak: "assets/bayraklar/sanmarino.png",
    enisim: "Sanmarino",
    isim: "Sanmarino",
    baskent: "Cityofsanmarino",
    kita: "Europe",
    bm: true,
    enlem: 43.77,
    boylam: 12.42,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/re.png",
    bayrak: "assets/bayraklar/reunion.png",
    enisim: "Reunion",
    isim: "Reunion",
    baskent: "Saintdenis",
    kita: "Africa",
    bm: false,
    enlem: -21.15,
    boylam: 55.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/va.png",
    bayrak: "assets/bayraklar/vatikan.png",
    enisim: "Vaticancity",
    isim: "Vatikan",
    baskent: "Vaticancity",
    kita: "Europe",
    bm: false,
    enlem: 41.9,
    boylam: 12.45,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bi.png",
    bayrak: "assets/bayraklar/burundi.png",
    enisim: "Burundi",
    isim: "Burundi",
    baskent: "Gitega",
    kita: "Africa",
    bm: true,
    enlem: -3.5,
    boylam: 30,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bh.png",
    bayrak: "assets/bayraklar/bahreyn.png",
    enisim: "Bahrain",
    isim: "Bahreyn",
    baskent: "Manama",
    kita: "Asia",
    bm: true,
    enlem: 26,
    boylam: 50.55,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mh.png",
    bayrak: "assets/bayraklar/marshalladalari.png",
    enisim: "Marshallislands",
    isim: "Marshalladalari",
    baskent: "Majuro",
    kita: "Oceania",
    bm: true,
    enlem: 9,
    boylam: 168,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tc.png",
    bayrak: "assets/bayraklar/turksvecaicosadalari.png",
    enisim: "Turksandcaicosislands",
    isim: "Turksvecaicosadalari",
    baskent: "Cockburntown",
    kita: "Americas",
    bm: false,
    enlem: 21.75,
    boylam: -71.58,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/im.png",
    bayrak: "assets/bayraklar/manadasi.png",
    enisim: "Isleofman",
    isim: "Manadasi",
    baskent: "Douglas",
    kita: "Europe",
    bm: false,
    enlem: 54.25,
    boylam: -4.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ht.png",
    bayrak: "assets/bayraklar/haiti.png",
    enisim: "Haiti",
    isim: "Haiti",
    baskent: "Portauprince",
    kita: "Americas",
    bm: true,
    enlem: 19,
    boylam: -72.42,
  ),
  Ulkeler(
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_the_Taliban.svg/320px-Flag_of_the_Taliban.svg.png",
    bayrak: "assets/bayraklar/afganistan.png",
    enisim: "Afghanistan",
    isim: "Afganistan",
    baskent: "Kabul",
    kita: "Asia",
    bm: true,
    enlem: 33,
    boylam: 65,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/il.png",
    bayrak: "assets/bayraklar/israil.png",
    enisim: "Israel",
    isim: "Israil",
    baskent: "Jerusalem",
    kita: "Asia",
    bm: true,
    enlem: 31.47,
    boylam: 35.13,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ly.png",
    bayrak: "assets/bayraklar/libya.png",
    enisim: "Libya",
    isim: "Libya",
    baskent: "Tripoli",
    kita: "Africa",
    bm: true,
    enlem: 25,
    boylam: 17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/uy.png",
    bayrak: "assets/bayraklar/uruguay.png",
    enisim: "Uruguay",
    isim: "Uruguay",
    baskent: "Montevideo",
    kita: "Americas",
    bm: true,
    enlem: -33,
    boylam: -56,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/nf.png",
    bayrak: "assets/bayraklar/norfolkadasi.png",
    enisim: "Norfolkisland",
    isim: "Norfolkadasi",
    baskent: "Kingston",
    kita: "Oceania",
    bm: false,
    enlem: -29.03,
    boylam: 167.95,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ni.png",
    bayrak: "assets/bayraklar/nikaragua.png",
    enisim: "Nicaragua",
    isim: "Nikaragua",
    baskent: "Managua",
    kita: "Americas",
    bm: true,
    enlem: 13,
    boylam: -85,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ck.png",
    bayrak: "assets/bayraklar/cookadalari.png",
    enisim: "Cookislands",
    isim: "Cookadalari",
    baskent: "Avarua",
    kita: "Oceania",
    bm: false,
    enlem: -21.23,
    boylam: -159.77,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/la.png",
    bayrak: "assets/bayraklar/laos.png",
    enisim: "Laos",
    isim: "Laos",
    baskent: "Vientiane",
    kita: "Asia",
    bm: true,
    enlem: 18,
    boylam: 105,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cx.png",
    bayrak: "assets/bayraklar/christmasadasi.png",
    enisim: "Christmasisland",
    isim: "Christmasadasi",
    baskent: "Flyingfishcove",
    kita: "Oceania",
    bm: false,
    enlem: -10.5,
    boylam: 105.67,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sh.png",
    bayrak: "assets/bayraklar/sainthelena.png",
    enisim: "Sainthelenaascensionandtristandacunha",
    isim: "Sainthelena",
    baskent: "Jamestown",
    kita: "Africa",
    bm: false,
    enlem: -15.95,
    boylam: -5.72,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ai.png",
    bayrak: "assets/bayraklar/anguilla.png",
    enisim: "Anguilla",
    isim: "Anguilla",
    baskent: "Thevalley",
    kita: "Americas",
    bm: false,
    enlem: 18.25,
    boylam: -63.17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/fm.png",
    bayrak: "assets/bayraklar/mikronezya.png",
    enisim: "Micronesia",
    isim: "Mikronezya",
    baskent: "Palikir",
    kita: "Oceania",
    bm: true,
    enlem: 6.92,
    boylam: 158.25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/de.png",
    bayrak: "assets/bayraklar/almanya.png",
    enisim: "Germany",
    isim: "Almanya",
    baskent: "Berlin",
    kita: "Europe",
    bm: true,
    enlem: 51,
    boylam: 9,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gu.png",
    bayrak: "assets/bayraklar/guam.png",
    enisim: "Guam",
    isim: "Guam",
    baskent: "HagÕt±a",
    kita: "Oceania",
    bm: false,
    enlem: 13.47,
    boylam: 144.78,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ki.png",
    bayrak: "assets/bayraklar/kiribati.png",
    enisim: "Kiribati",
    isim: "Kiribati",
    baskent: "Southtarawa",
    kita: "Oceania",
    bm: true,
    enlem: 1.42,
    boylam: 173,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sx.png",
    bayrak: "assets/bayraklar/sintmaarten.png",
    enisim: "Sintmaarten",
    isim: "Sintmaarten",
    baskent: "Philipsburg",
    kita: "Americas",
    bm: false,
    enlem: 18.03,
    boylam: -63.05,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/es.png",
    bayrak: "assets/bayraklar/ispanya.png",
    enisim: "Spain",
    isim: "Ispanya",
    baskent: "Madrid",
    kita: "Europe",
    bm: true,
    enlem: 40,
    boylam: -4,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/jm.png",
    bayrak: "assets/bayraklar/jamaika.png",
    enisim: "Jamaica",
    isim: "Jamaika",
    baskent: "Kingston",
    kita: "Americas",
    bm: true,
    enlem: 18.25,
    boylam: -77.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ps.png",
    bayrak: "assets/bayraklar/filistin.png",
    enisim: "Palestine",
    isim: "Filistin",
    baskent: "Ramallahjerusalem",
    kita: "Asia",
    bm: false,
    enlem: 31.9,
    boylam: 35.2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gf.png",
    bayrak: "assets/bayraklar/fransizguyanasi.png",
    enisim: "Frenchguiana",
    isim: "Fransizguyanasi",
    baskent: "Cayenne",
    kita: "Americas",
    bm: false,
    enlem: 4,
    boylam: -53,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ad.png",
    bayrak: "assets/bayraklar/andorra.png",
    enisim: "Andorra",
    isim: "Andorra",
    baskent: "Andorralavella",
    kita: "Europe",
    bm: true,
    enlem: 42.5,
    boylam: 1.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cl.png",
    bayrak: "assets/bayraklar/sili.png",
    enisim: "Chile",
    isim: "Sili",
    baskent: "Santiago",
    kita: "Americas",
    bm: true,
    enlem: -30,
    boylam: -71,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ls.png",
    bayrak: "assets/bayraklar/lesotho.png",
    enisim: "Lesotho",
    isim: "Lesotho",
    baskent: "Maseru",
    kita: "Africa",
    bm: true,
    enlem: -29.5,
    boylam: 28.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/au.png",
    bayrak: "assets/bayraklar/avustralya.png",
    enisim: "Australia",
    isim: "Avustralya",
    baskent: "Canberra",
    kita: "Oceania",
    bm: true,
    enlem: -27,
    boylam: 133,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gd.png",
    bayrak: "assets/bayraklar/grenada.png",
    enisim: "Grenada",
    isim: "Grenada",
    baskent: "St. George's",
    kita: "Americas",
    bm: true,
    enlem: 12.12,
    boylam: -61.67,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gh.png",
    bayrak: "assets/bayraklar/gana.png",
    enisim: "Ghana",
    isim: "Gana",
    baskent: "Accra",
    kita: "Africa",
    bm: true,
    enlem: 8,
    boylam: -2,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sc.png",
    bayrak: "assets/bayraklar/seyseller.png",
    enisim: "Seychelles",
    isim: "Seyseller",
    baskent: "Victoria",
    kita: "Africa",
    bm: true,
    enlem: -4.58,
    boylam: 55.67,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ao.png",
    bayrak: "assets/bayraklar/angola.png",
    enisim: "Angola",
    isim: "Angola",
    baskent: "Luanda",
    kita: "Africa",
    bm: true,
    enlem: -12.5,
    boylam: 18.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bm.png",
    bayrak: "assets/bayraklar/bermuda.png",
    enisim: "Bermuda",
    isim: "Bermuda",
    baskent: "Hamilton",
    kita: "Americas",
    bm: false,
    enlem: 32.33,
    boylam: -64.75,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pk.png",
    bayrak: "assets/bayraklar/pakistan.png",
    enisim: "Pakistan",
    isim: "Pakistan",
    baskent: "Islamabad",
    kita: "Asia",
    bm: true,
    enlem: 30,
    boylam: 70,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ml.png",
    bayrak: "assets/bayraklar/mali.png",
    enisim: "Mali",
    isim: "Mali",
    baskent: "Bamako",
    kita: "Africa",
    bm: true,
    enlem: 17,
    boylam: -4,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sa.png",
    bayrak: "assets/bayraklar/suudiarabistan.png",
    enisim: "Saudi Arabia",
    isim: "Suudiarabistan",
    baskent: "Riyadh",
    kita: "Asia",
    bm: true,
    enlem: 25,
    boylam: 45,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cw.png",
    bayrak: "assets/bayraklar/curacao.png",
    enisim: "Curaao",
    isim: "Curacao",
    baskent: "Willemstad",
    kita: "Americas",
    bm: false,
    enlem: 12.12,
    boylam: -68.93,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/kr.png",
    bayrak: "assets/bayraklar/guneykore.png",
    enisim: "South Korea",
    isim: "Güney Kore",
    baskent: "Seoul",
    kita: "Asia",
    bm: true,
    enlem: 37,
    boylam: 127.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/et.png",
    bayrak: "assets/bayraklar/etiyopya.png",
    enisim: "Ethiopia",
    isim: "Etiyopya",
    baskent: "Addis Ababa",
    kita: "Africa",
    bm: true,
    enlem: 8,
    boylam: 38,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gp.png",
    bayrak: "assets/bayraklar/guadeloupe.png",
    enisim: "Guadeloupe",
    isim: "Guadeloupe",
    baskent: "Basseterre",
    kita: "Americas",
    bm: false,
    enlem: 16.25,
    boylam: -61.58,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bd.png",
    bayrak: "assets/bayraklar/banglades.png",
    enisim: "Bangladesh",
    isim: "Banglades",
    baskent: "Dhaka",
    kita: "Asia",
    bm: true,
    enlem: 24,
    boylam: 90,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/nz.png",
    bayrak: "assets/bayraklar/yenizelanda.png",
    enisim: "New Zealand",
    isim: "Yeni Zelanda",
    baskent: "Wellington",
    kita: "Oceania",
    bm: true,
    enlem: -41,
    boylam: 174,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/km.png",
    bayrak: "assets/bayraklar/komorlar.png",
    enisim: "Comoros",
    isim: "Komorlar",
    baskent: "Moroni",
    kita: "Africa",
    bm: true,
    enlem: -12.17,
    boylam: 44.25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bz.png",
    bayrak: "assets/bayraklar/belize.png",
    enisim: "Belize",
    isim: "Belize",
    baskent: "Belmopan",
    kita: "Americas",
    bm: true,
    enlem: 17.25,
    boylam: -88.75,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ug.png",
    bayrak: "assets/bayraklar/uganda.png",
    enisim: "Uganda",
    isim: "Uganda",
    baskent: "Kampala",
    kita: "Africa",
    bm: true,
    enlem: 1,
    boylam: 32,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sg.png",
    bayrak: "assets/bayraklar/singapur.png",
    enisim: "Singapore",
    isim: "Singapur",
    baskent: "Singapore",
    kita: "Asia",
    bm: true,
    enlem: 1.37,
    boylam: 103.8,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/li.png",
    bayrak: "assets/bayraklar/lihtenstayn.png",
    enisim: "Liechtenstein",
    isim: "Lihtenstayn",
    baskent: "Vaduz",
    kita: "Europe",
    bm: true,
    enlem: 47.27,
    boylam: 9.53,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/hu.png",
    bayrak: "assets/bayraklar/macaristan.png",
    enisim: "Hungary",
    isim: "Macaristan",
    baskent: "Budapest",
    kita: "Europe",
    bm: true,
    enlem: 47,
    boylam: 20,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/is.png",
    bayrak: "assets/bayraklar/izlanda.png",
    enisim: "Iceland",
    isim: "Izlanda",
    baskent: "Reykjavik",
    kita: "Europe",
    bm: true,
    enlem: 65,
    boylam: -18,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tj.png",
    bayrak: "assets/bayraklar/tacikistan.png",
    enisim: "Tajikistan",
    isim: "Tacikistan",
    baskent: "Dushanbe",
    kita: "Asia",
    bm: true,
    enlem: 39,
    boylam: 71,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/na.png",
    bayrak: "assets/bayraklar/namibya.png",
    enisim: "Namibia",
    isim: "Namibya",
    baskent: "Windhoek",
    kita: "Africa",
    bm: true,
    enlem: -22,
    boylam: 17,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/tl.png",
    bayrak: "assets/bayraklar/dogutimor.png",
    enisim: "Timorleste",
    isim: "Dogutimor",
    baskent: "Dili",
    kita: "Asia",
    bm: true,
    enlem: -8.83,
    boylam: 125.92,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/eg.png",
    bayrak: "assets/bayraklar/misir.png",
    enisim: "Egypt",
    isim: "Misir",
    baskent: "Cairo",
    kita: "Africa",
    bm: true,
    enlem: 27,
    boylam: 30,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/rs.png",
    bayrak: "assets/bayraklar/sirbistan.png",
    enisim: "Serbia",
    isim: "Sirbistan",
    baskent: "Belgrade",
    kita: "Europe",
    bm: true,
    enlem: 44,
    boylam: 21,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mu.png",
    bayrak: "assets/bayraklar/mauritius.png",
    enisim: "Mauritius",
    isim: "Mauritius",
    baskent: "Portlouis",
    kita: "Africa",
    bm: true,
    enlem: -20.28,
    boylam: 57.55,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mo.png",
    bayrak: "assets/bayraklar/makao.png",
    enisim: "Macau",
    isim: "Makao",
    baskent: "",
    kita: "Asia",
    bm: false,
    enlem: 22.17,
    boylam: 113.55,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/pf.png",
    bayrak: "assets/bayraklar/fransizpolinezyasi.png",
    enisim: "French Polynesia",
    isim: "Fransız Polinezyası",
    baskent: "Papeete",
    kita: "Oceania",
    bm: false,
    enlem: 17.68,
    boylam: 149.41,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mv.png",
    bayrak: "assets/bayraklar/maldivler.png",
    enisim: "Maldives",
    isim: "Maldivler",
    baskent: "Malé",
    kita: "Asia",
    bm: true,
    enlem: 3.25,
    boylam: 73,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/id.png",
    bayrak: "assets/bayraklar/endonezya.png",
    enisim: "Indonesia",
    isim: "Endonezya",
    baskent: "Jakarta",
    kita: "Asia",
    bm: true,
    enlem: -5,
    boylam: 120,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/cd.png",
    bayrak: "assets/bayraklar/demokratikkongocumhuriyeti.png",
    enisim: "Drcongo",
    isim: "Demokratikkongocumhuriyeti",
    baskent: "Kinshasa",
    kita: "Africa",
    bm: true,
    enlem: 0,
    boylam: 25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ee.png",
    bayrak: "assets/bayraklar/estonya.png",
    enisim: "Estonia",
    isim: "Estonya",
    baskent: "Tallinn",
    kita: "Europe",
    bm: true,
    enlem: 59,
    boylam: 26,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/vn.png",
    bayrak: "assets/bayraklar/vietnam.png",
    enisim: "Vietnam",
    isim: "Vietnam",
    baskent: "Hanoi",
    kita: "Asia",
    bm: true,
    enlem: 16.17,
    boylam: 107.83,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/it.png",
    bayrak: "assets/bayraklar/italya.png",
    enisim: "Italy",
    isim: "Italya",
    baskent: "Rome",
    kita: "Europe",
    bm: true,
    enlem: 42.83,
    boylam: 12.83,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/gn.png",
    bayrak: "assets/bayraklar/gine.png",
    enisim: "Guinea",
    isim: "Gine",
    baskent: "Conakry",
    kita: "Africa",
    bm: true,
    enlem: 11,
    boylam: -10,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/td.png",
    bayrak: "assets/bayraklar/cad.png",
    enisim: "Chad",
    isim: "Cad",
    baskent: "Ndjamena",
    kita: "Africa",
    bm: true,
    enlem: 15,
    boylam: 19,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ec.png",
    bayrak: "assets/bayraklar/ekvador.png",
    enisim: "Ecuador",
    isim: "Ekvador",
    baskent: "Quito",
    kita: "Americas",
    bm: true,
    enlem: -2,
    boylam: -77.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ge.png",
    bayrak: "assets/bayraklar/gurcistan.png",
    enisim: "Georgia",
    isim: "Gurcistan",
    baskent: "Tbilisi",
    kita: "Asia",
    bm: true,
    enlem: 42,
    boylam: 43.5,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/mw.png",
    bayrak: "assets/bayraklar/malavi.png",
    enisim: "Malawi",
    isim: "Malavi",
    baskent: "Lilongwe",
    kita: "Africa",
    bm: true,
    enlem: -13.5,
    boylam: 34,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/iq.png",
    bayrak: "assets/bayraklar/irak.png",
    enisim: "Iraq",
    isim: "Irak",
    baskent: "Baghdad",
    kita: "Asia",
    bm: true,
    enlem: 33,
    boylam: 44,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/sj.png",
    bayrak: "assets/bayraklar/svalbardvejanmayen.png",
    enisim: "Svalbard and Jan Mayen",
    isim: "Svalbard ve Jan Mayen",
    baskent: "Longyearbyen",
    kita: "Europe",
    bm: false,
    enlem: 78,
    boylam: 20,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/bj.png",
    bayrak: "assets/bayraklar/benin.png",
    enisim: "Benin",
    isim: "Benin",
    baskent: "Porto-Novo",
    kita: "Africa",
    bm: true,
    enlem: 9.5,
    boylam: 2.25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/jp.png",
    bayrak: "assets/bayraklar/japonya.png",
    enisim: "Japan",
    isim: "Japonya",
    baskent: "Tokyo",
    kita: "Asia",
    bm: true,
    enlem: 36,
    boylam: 138,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/do.png",
    bayrak: "assets/bayraklar/dominikcumhuriyeti.png",
    enisim: "Dominicanrepublic",
    isim: "Dominikcumhuriyeti",
    baskent: "Santo Domingo",
    kita: "Americas",
    bm: true,
    enlem: 19,
    boylam: -70.67,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/qa.png",
    bayrak: "assets/bayraklar/katar.png",
    enisim: "Qatar",
    isim: "Katar",
    baskent: "Doha",
    kita: "Asia",
    bm: true,
    enlem: 25.5,
    boylam: 51.25,
  ),
  Ulkeler(
    url: "https://flagcdn.com/w320/ga.png",
    bayrak: "assets/bayraklar/gabon.png",
    enisim: "Gabon",
    isim: "Gabon",
    baskent: "Libreville",
    kita: "Africa",
    bm: true,
    enlem: -1,
    boylam: 11.75,
  ),
];
