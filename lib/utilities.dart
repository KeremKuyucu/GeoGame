import 'package:geogame/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _sebepController = TextEditingController();
    final TextEditingController _messageController = TextEditingController();

    Future<void> sendMessage(String sebep, String message) async {
      void _showResult(String baslik, String metin) {
        showDialog(
          context: context,
          builder: (context) {
            return CustomNotification(
              baslik: baslik,
              metin: metin,
            );
          },
        );
      }
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        _showResult(
            Yazi.get('hata_baslik'),
            Yazi.get('giris_yap_mesaj'),
        );
        return;
      }

      try {
        await Supabase.instance.client.from('feedbacks').insert({
          'sebep': sebep,
          'message': message,
          'isim': name, // Sınıfındaki isim değişkeni
          'user_id': user.id,
        });

        // Başarılı durumu
        _showResult(
            Yazi.get('basarili_baslik'),
            Yazi.get('feedback_gonderildi')
        );

      } catch (e) {
        // Başarısız durumu
        _showResult(
            Yazi.get('hata_baslik'),
            "Bir sorun oluştu: $e"
        );
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
            title: Text(
              Yazi.get('hatabildir'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                          _buildTextField(
                            _sebepController,
                            Yazi.get('hatabaslik'),
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            _messageController,
                            Yazi.get('hatametin'),
                          ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
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
          _buildListTile(
            Icons.share,
            Color(0xFF5865F2),
            Yazi.get('uygpaylas'),
            () async {
              await Share.share(Yazi.get('davetpromt'));
            },
          ),
          _buildListTile(
            Icons.person,
            Color(0xFF5865F2),
            Yazi.get('yapimcimetin'),
            () async {
              await EasyLauncher.url(
                url: 'https://keremkk.com.tr',
                mode: Mode.platformDefault,
              );
            },
          ),
          _buildListTile(
            Icons.public,
            Colors.red,
            Yazi.get('website'),
            () async {
              await EasyLauncher.url(url: 'https://keremkk.com.tr/geogame');
            },
          ),
          _buildListTile(
            FontAwesomeIcons.github,
            Colors.black,
            Yazi.get('github'),
            () async {
              await EasyLauncher.url(
                url: 'https://github.com/KeremKuyucu/GeoGame',
              );
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

  Widget _buildListTile(
    IconData icon,
    Color iconColor,
    String title,
    Function() onTap,
  ) {
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

  CustomNotification({required this.baslik, required this.metin});

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
              Text(baslik, style: TextStyle(fontSize: 18, color: Colors.white)),
              SizedBox(height: 10),
              Text(metin, style: TextStyle(fontSize: 16, color: Colors.white)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 4.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Bildirimi kapat
                        },
                        child: Text(
                          Yazi.get('tamam'),
                          style: TextStyle(color: Colors.black),
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

class GameFilter {
  bool amerika;
  bool asya;
  bool afrika;
  bool avrupa;
  bool okyanusya;
  bool antarktika;

  bool onlyUN;
  bool justUN; // sadecebm

  GameFilter({
    this.amerika = true,
    this.asya = true,
    this.afrika = true,
    this.avrupa = true,
    this.okyanusya = true,
    this.antarktika = true,
    this.onlyUN = false,
    this.justUN = false,
  });
}
class AppSettings {
  bool darkTheme;
  bool isEnglish;
  String languageCode; // secilenDil

  AppSettings({
    this.darkTheme = true,
    this.isEnglish = false,
    this.languageCode = '',
  });
}
class UserProfile {
  final String uid;
  final String name;
  final String avatarUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.avatarUrl,
  });

  bool get isLoggedIn => uid.isNotEmpty;
}
class GameStats {
  int mesafeDogru;
  int mesafeYanlis;
  int bayrakDogru;
  int bayrakYanlis;
  int baskentDogru;
  int baskentYanlis;

  int mesafePuan;
  int bayrakPuan;
  int baskentPuan;

  GameStats({
    this.mesafeDogru = 0,
    this.mesafeYanlis = 0,
    this.bayrakDogru = 0,
    this.bayrakYanlis = 0,
    this.baskentDogru = 0,
    this.baskentYanlis = 0,
    this.mesafePuan = 0,
    this.bayrakPuan = 0,
    this.baskentPuan = 0,
  });

  int get toplamPuan =>
      mesafePuan + bayrakPuan + baskentPuan;
}

bool amerikakitasi = true,
    asyakitasi = true,
    afrikakitasi = true,
    avrupakitasi = true,
    okyanusyakitasi = true,
    antartikakitasi = true,
    bmuyeligi = false,
    sadecebm = false,
    yazmamodu = true,
    darktema = true,
    isEnglish = false;
String diltercihi = '';
int mesafedogru = 0,
    mesafeyanlis = 0,
    bayrakdogru = 0,
    bayrakyanlis = 0,
    baskentdogru = 0,
    baskentyanlis = 0,
    mesafepuan = 0,
    bayrakpuan = 0,
    baskentpuan = 0,
    toplampuan = 0,
    selectedIndex = 0;
String name = "",
    profilurl = "https://geogame-cdn.keremkk.com.tr/anon.png",
    uid = '',
    secilenDil = '';
List<dynamic> users = [];
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

final _supabase = Supabase.instance.client;
Future<void> readFromFile(Function updateState) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/geogame.json';
  final file = File(filePath);

  if (await file.exists()) {
    try {
      final contents = await file.readAsString();
      final jsonData = jsonDecode(contents);

      updateState(() {
        // Ayarlar
        amerikakitasi = jsonData['amerikakitasi'] == true;
        asyakitasi = jsonData['asyakitasi'] == true;
        afrikakitasi = jsonData['afrikakitasi'] == true;
        avrupakitasi = jsonData['avrupakitasi'] == true;
        okyanusyakitasi = jsonData['okyanusyakitasi'] == true;
        antartikakitasi = jsonData['antartikakitasi'] == true;
        bmuyeligi = jsonData['bmuyeligi'] == true;
        yazmamodu = jsonData['yazmamodu'] == true;
        darktema = jsonData['darktema'] == true;

        // Kullanıcı Bilgileri
        name = jsonData['name'] ?? '';
        uid = jsonData['uid'] ?? '';
        profilurl = jsonData['profilurl'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';
        secilenDil = jsonData['secilenDil'] ?? 'English';

        // İstatistikler
        toplampuan = jsonData['toplampuan'] ?? 0;

        mesafedogru = jsonData['mesafedogru'] ?? 0;
        mesafeyanlis = jsonData['mesafeyanlis'] ?? 0;
        mesafepuan = jsonData['mesafepuan'] ?? 0;

        bayrakdogru = jsonData['bayrakdogru'] ?? 0;
        bayrakyanlis = jsonData['bayrakyanlis'] ?? 0;
        bayrakpuan = jsonData['bayrakpuan'] ?? 0;

        baskentdogru = jsonData['baskentdogru'] ?? 0;
        baskentyanlis = jsonData['baskentyanlis'] ?? 0;
        baskentpuan = jsonData['baskentpuan'] ?? 0;

        debugPrint("Yerel dosyadan veriler yüklendi.");
      });

      // Eğer kullanıcı giriş yapmışsa, bulut verisini kontrol et (Senkronizasyon)
      if (uid.isNotEmpty) {
        await puanguncelle();
      }

    } catch (e) {
      debugPrint('Dosya okuma hatası: $e');
    }
  } else {
    debugPrint('Dosya bulunamadı, varsayılan oluşturuluyor...');
    writeToFile();
  }
}
Future<void> writeToFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/geogame.json';
  final file = File(filePath);

  // Toplam puanı hesapla
  toplampuan = bayrakpuan + baskentpuan + mesafepuan;

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

  try {
    final jsonData = jsonEncode(data);
    await file.writeAsString(jsonData);
    debugPrint("Yerel dosyaya yazıldı.");

  } catch (e) {
    debugPrint('Dosya yazma hatası: $e');
  }
}
Future<void> puanguncelle() async {
  if (uid.isEmpty) return;

  try {
    final data = await _supabase
        .from('geogame_stats')
        .select(
      'puan, mesafepuan, bayrakpuan, baskentpuan, '
          'mesafedogru, mesafeyanlis, '
          'bayrakdogru, bayrakyanlis, '
          'baskentdogru, baskentyanlis',
    )
        .eq('user_id', uid)
        .maybeSingle();

    if (data == null) return;

    final cloudPuan = (data['puan'] ?? 0) as int;

    // 🔹 Bulut > Local → Local güncelle
    if (cloudPuan > toplampuan) {
      debugPrint(
        '☁️ Bulut puanı ($cloudPuan) yerel puandan ($toplampuan) yüksek. Senkronize ediliyor...',
      );

      toplampuan = cloudPuan;

      mesafepuan = data['mesafepuan'] ?? 0;
      bayrakpuan = data['bayrakpuan'] ?? 0;
      baskentpuan = data['baskentpuan'] ?? 0;

      mesafedogru = data['mesafedogru'] ?? 0;
      mesafeyanlis = data['mesafeyanlis'] ?? 0;
      bayrakdogru = data['bayrakdogru'] ?? 0;
      bayrakyanlis = data['bayrakyanlis'] ?? 0;
      baskentdogru = data['baskentdogru'] ?? 0;
      baskentyanlis = data['baskentyanlis'] ?? 0;

      await writeToFile();
    }

    // 🔹 Local > Bulut → Buluta gönder
    else if (toplampuan > cloudPuan) {
      debugPrint('📤 Yerel puan daha yüksek. Buluta gönderiliyor...');

      await _supabase.from('geogame_stats').upsert({
        'user_id': uid,
        'puan': toplampuan,

        'mesafepuan': mesafepuan,
        'mesafedogru': mesafedogru,
        'mesafeyanlis': mesafeyanlis,

        'bayrakpuan': bayrakpuan,
        'bayrakdogru': bayrakdogru,
        'bayrakyanlis': bayrakyanlis,

        'baskentpuan': baskentpuan,
        'baskentdogru': baskentdogru,
        'baskentyanlis': baskentyanlis,

        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      debugPrint('✅ Skorlar Supabase\'e gönderildi');
    }
  } catch (e) {
    debugPrint('❌ Puan senkronizasyon hatası: $e');
  }
}

Future<void> sendAnalytics() async {
  final session = _supabase.auth.currentSession;

  final response = await _supabase.functions.invoke(
    'collect-analytics',
    headers: session != null
        ? {
      'Authorization': 'Bearer ${session.accessToken}',
    }
        : null, // session yoksa anonim gider
    body: {
      'appId': 'geogame',
      'uid': uid,
      'endpoint': '/page/main',
    },
  );
  //debugPrint("Analytics response: ${response.data}");
}