import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:GeoGame/screens/settings.dart';
import 'package:GeoGame/screens/geogamelobi.dart';
import 'package:GeoGame/screens/profiles.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

class Leadboard extends StatefulWidget {
  @override
  _LeadboardState createState() => _LeadboardState();
}

class _LeadboardState extends State<Leadboard> {
  List<Map<String, dynamic>> users = [];
  @override
  void initState() {
    super.initState();
    _fetchData();
    _initializeGame();
  }
  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
  }
  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1 && getSelectableCountryCount() > 0) {
      //aynı sayfa
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
  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://fresh-arrow-ox.glitch.me/download_file'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Bu alanda gelen veriyi işleyebilirsiniz
          print(data);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('navigasyonbar2')),
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

      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
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
