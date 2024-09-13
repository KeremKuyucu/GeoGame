import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:GeoGame/screens/baskentoyun.dart';
import 'package:GeoGame/screens/bayrakoyun.dart';
import 'package:GeoGame/screens/mesafeoyun.dart';
import 'package:GeoGame/screens/settings_page.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:theme_mode_builder/theme_mode_builder.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GeoGameLobi extends StatefulWidget {
  @override
  _GeoGameLobiState createState() => _GeoGameLobiState();
}
class _GeoGameLobiState extends State<GeoGameLobi> {
  int _selectedOption = 0;
  final List<String> _options = [
    '1. Baskentden Ülke Bilme Oyunu',
    '2. Bayraktan Ülke Bilme Oyunu',
    '3. Mesafeden Ülke Bilme Oyunu',
    '4. Ayarlar',
  ];
  @override
  void initState() {
    super.initState();
      surumkiyasla();
      ThemeModeBuilderConfig.setSystem();
      readFromFile((update) => setState(update));
  }

  Future<void> surumkiyasla() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String? remoteVersion;
    String? apkUrl;

    // Verileri fetch eden asenkron fonksiyon
    Future<void> _fetchData() async {
      try {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/keremlolgg/GeoGame/main/latest_version.json'));
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
            title: Text('Yeni Sürüm Var'),
            content: Text('Lütfen internet sitesinden uygulamayı tekrar indirerek güncelleyiniz.'),
            actions: <Widget>[
              TextButton(
                child: Text('Şimdi Değil'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Siteye Git'),
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
    if (remoteVersion != null && apkUrl != null && remoteVersion != localVersion) {
      showUpdateDialog(context);
    }
  }
  void _selectOption(int index) async {
   setState(() {
     _selectedOption = index;
   });
   if (_selectedOption == 0 && true == (amerikakitasi || asyakitasi || afrikakitasi || avrupakitasi || okyanusyakitasi || antartikakitasi)) {
     Yenitur();
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => BaskentOyun()),
     );
   } else if (_selectedOption == 1 && true == (amerikakitasi || asyakitasi || afrikakitasi || avrupakitasi || okyanusyakitasi || antartikakitasi)) {
     Yenitur();
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => BayrakOyun()),
     );
   } else if (_selectedOption == 2 && true == (amerikakitasi || asyakitasi || afrikakitasi || avrupakitasi || okyanusyakitasi || antartikakitasi)) {
     Yenitur();
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => MesafeOyun()),
     );
   } else if (_selectedOption == 3 || false == (amerikakitasi || asyakitasi || afrikakitasi || avrupakitasi || okyanusyakitasi || antartikakitasi)) {
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
                'Oyunla ilgili şikayet veya önerilerini discord veya instagram yazabilirsiniz.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.share, color: Color(0xFF5865F2)),
              title: Text('Uygulamayı Paylaş'),
              onTap: () async {
                await Share.share('GeoGame Adlı Oyunu Oynamak İçin Davet Edildiniz. https://geogame.glitch.me');
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.instagram),
              title: Text('Instagram Hesabım'),
              onTap: () async {
                await EasyLauncher.url(
                    url: "https://www.instagram.com/kerem_kk0",
                    mode: Mode.platformDefault);
              },
            ),
            ListTile(
              leading: Icon(Icons.public, color: Colors.red),
              title: Text('Oyunun İnternet Sitesi'),
              onTap: () async {
                await EasyLauncher.url(url: "https://geogame.glitch.me/");
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.github),
              title: Text('Oyunun Github Sayfası'),
              onTap: () async {
                await EasyLauncher.url(url: "https://geogame.glitch.me/");
              },
            ),
            ListTile(
              leading: Icon(Icons.discord, color: Color(0xFF5865F2)),
              title: Text('Discord Hesabım'),
              onTap: () async {
                await EasyLauncher.url(url: "https://discord.com/users/483678328646270996");
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.red),
              title: Text('Just Weirdness'),
              onTap: () async {
                await EasyLauncher.url(url: "https://www.youtube.com/watch?v=8HcpPysIDy4");
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Yapımcı: Kerem Kuyucu',
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
              'Seçeneklerden Birini Seçin:',
              style: TextStyle(fontSize: 24,color: Colors.blue),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: _selectedOption == index ? Colors.blueAccent : Colors.grey[800],
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
                        _options[index],
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
              'Toplam Puan:\n${toplampuan}', // max 17 basamak
              style: TextStyle(fontSize: 35,color: Colors.green),
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
                'Ayarlardan Şarkı Açabilirsiniz.\nSes efektleri için şarkı gerekmektedir.',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
