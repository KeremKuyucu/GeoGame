import 'package:GeoGame/screens/leadboard.dart';
import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:GeoGame/screens/games/baskentoyun.dart';
import 'package:GeoGame/screens/games/bayrakoyun.dart';
import 'package:GeoGame/screens/games/mesafeoyun.dart';
import 'package:GeoGame/screens/profiles.dart';
import 'package:GeoGame/screens/settings.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:theme_mode_builder/theme_mode_builder.dart";
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:http/http.dart' as http;
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
  List<String> options = List.filled(3, '');
  final List<Map<String, String>> modes = [
    {
      "title": "Başkentten Ülke Bilme",
      "description": "Başkentten ülkeyi tanıyın",
      "image": "dosyalar/baskent.jpg",
    },
    {
      "title": "Bayraktan Ülke Bilme",
      "description": "Bayraktan ülkeyi tanıyın",
      "image": "dosyalar/bayrak.jpg",
    },
    {
      "title": "Mesafeden Ülke Bilme",
      "description": "Mesafe ve yön bilgisine göre ülkeleri tahmin edin.",
      "image": "dosyalar/mesafe.jpg",
    },
  ];
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
    dilDegistir();
    if (darktema)
      ThemeModeBuilderConfig.setDark();
    else
      ThemeModeBuilderConfig.setLight();
    istatistik(context);
  }
  void dilDegistir() {
    Yazi.loadDil(secilenDil).then((_) {
      setState(() {
        options[0] = Yazi.get('game1');
        options[1] = Yazi.get('game2');
        options[2] = Yazi.get('game3');
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
            title: Text(Yazi.get('navigasyonbar4')),
            selectedColor: Colors.teal,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: Text(Yazi.get('navigasyonbar3')),
            selectedColor: Colors.orange,
          ),
        ];
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
    name = await getNameFromFile();

    if (name.isEmpty) {
      await isimgirbox(context);
      await sendMessage('Yeni bir kullanıcı oyunu yükledi');
    } else {
      await sendMessage('Log mesajı');
    }
  }
  Future<void> isimgirbox(BuildContext context) async {
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
                  saveNameToFile(name);
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
    }
  }
  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0 && getSelectableCountryCount() > 0) {
      //zaten aynı sayfa
    } else if (selectedIndex == 1 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2 || getSelectableCountryCount() == 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 3 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: modes.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  _selectOption(index);
                  print("${modes[index]["title"]} seçildi.");
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          modes[index]["image"]!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              modes[index]["title"]!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              modes[index]["description"]!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) async {
          setState(() {
            selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}
