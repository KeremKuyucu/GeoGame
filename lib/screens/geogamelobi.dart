import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:GeoGame/screens/baskentoyun.dart';
import 'package:GeoGame/screens/bayrakoyun.dart';
import 'package:GeoGame/screens/mesafeoyun.dart';
import 'package:GeoGame/screens/settings_page.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:theme_mode_builder/theme_mode_builder.dart";
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

void disableCertificateVerification() {
  HttpOverrides.global = MyHttpOverrides();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;  // Sertifika doğrulamasını geç
    return client;
  }
}

class GeoGameLobi extends StatefulWidget {
  @override
  _GeoGameLobiState createState() => _GeoGameLobiState();
}

class _GeoGameLobiState extends State<GeoGameLobi> {
  int _selectedOption = 0;
  List<String> options = List.filled(4, '');
  @override
  void initState() {
    super.initState();
    surumkiyasla();
    yeniulkesec();
    readFromFile((update) {
      if (mounted) {
        setState(update);
      }
    });
    istatistik(context);
    dilDegistir();
    if (darktema)
      ThemeModeBuilderConfig.setDark();
    else
      ThemeModeBuilderConfig.setLight();
  }
  void dilDegistir() {
    Yazi.loadDil(secilenDil).then((_) {
      setState(() {
        options[0] = Yazi.get('game1');
        options[1] = Yazi.get('game2');
        options[2] = Yazi.get('game3');
        options[3] = Yazi.get('game4');
      });
    });
    isEnglish = (secilenDil != 'Türkçe');
  }
  Future<void> surumkiyasla() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String? remoteVersion;
    String? apkUrl;

    Future<void> _fetchData() async {
      try {
        final response = await http.get(Uri.parse(
            'https://raw.githubusercontent.com/keremlolgg/GeoGame/main/latest_version.json'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            remoteVersion = data['latest_version'];
            apkUrl = data['apk_url'];
          });
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    await _fetchData();
    void showUpdateDialog(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Yazi.get('surum1')),
            content: Text(Yazi.get('surum2')),
            actions: <Widget>[
              TextButton(
                child: Text(Yazi.get('surum3')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(Yazi.get('surum4')),
                onPressed: () {
                  Navigator.of(context).pop();
                  EasyLauncher.url(
                    url: apkUrl!,
                  );
                },
              ),
            ],
          );
        },
      );
    }

    if (remoteVersion != null &&
        apkUrl != null &&
        remoteVersion != localVersion) {
      showUpdateDialog(context);
    }
  }
  Future<void> istatistik(BuildContext context) async {
    final name = await _getNameFromFile();
    if (name == null || name.isEmpty) {
      isimgirbox(context);
      await sendMessageToDiscord('Yeni bir kullanıcı oyunu yükledi ismi: $name');
    } else {
      // setState'i yalnızca widget aktifse çağırın
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${Yazi.get('isimsorma5')} $name')),
        );
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String localVersion = packageInfo.version;
        String country = (await getCountry()).replaceAll('\n', '');
        String city = await getCity();
        await sendMessageToDiscord('$name, oyuna tekrardan giriş yaptı.\nPuanı: $toplampuan,\nDili: $secilenDil,\nSürüm: $localVersion,\nÜlke: $country,\nŞehir: $city');
      }
    }
  }
  Future<void> sendMessageToDiscord(String message) async {
    // URL'yi JSON dosyasından al
    String webhookUrl = await getWebhookUrlFromFile();

    // Mesaj gönderilecek payload
    final payload = json.encode({
      'content': message, // Gönderilecek mesaj
    });

    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: payload,
      );

      if (response.statusCode == 204) {
        print('Mesaj başarıyla gönderildi!');
      } else {
        print('Mesaj gönderilemedi. Hata kodu: ${response.statusCode}');
        print('Sunucu yanıtı: ${response.body}');
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
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
  void isimgirbox(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('isimsorma1')),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: Yazi.get('isimsorma2')),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Yazi.get('isimsorma3')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(Yazi.get('isimsorma4')),
              onPressed: () {
                String name = nameController.text;
                Navigator.of(context).pop();
                if (name.isNotEmpty) {
                  _saveNameToFile(name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${Yazi.get('isimsorma5')} $name'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(Yazi.get('isimsorma6'))),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  Future<String?> _getNameFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/dosyalar/isim.json');
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final data = json.decode(content);
      return data['isim'];
    } catch (e) {
      print('Error reading name: $e');
      return null;
    }
  }
  Future<void> _saveNameToFile(String name) async {
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

  void _selectOption(int index) async {
    setState(() {
      _selectedOption = index;
    });
    if (_selectedOption == 0 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BaskentOyun()),
      );
    } else if (_selectedOption == 1 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BayrakOyun()),
      );
    } else if (_selectedOption == 2 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MesafeOyun()),
      );
    } else if (_selectedOption == 3 || getSelectableCountryCount() == 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GeoGame',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
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
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              Yazi.get('secenek'),
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: _selectedOption == index
                        ? Colors.blueAccent
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _selectOption(index),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        options[index], // Güncellenmiş veriyi kullan
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              Yazi.get('puan') + toplampuan.toString(), // max 17 basamak
              style: TextStyle(fontSize: 35, color: Colors.green),
            ),
          ),
          Card(
            margin: EdgeInsets.all(16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Container(
              color: Colors.grey.shade800,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                Yazi.get('lobiuyari'),
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
