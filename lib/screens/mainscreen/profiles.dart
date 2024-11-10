import 'package:flutter/material.dart';
import 'package:GeoGame/utilities.dart';
import 'package:GeoGame/screens/mainscreen/settings.dart';
import 'package:GeoGame/screens/mainscreen/geogamelobi.dart';
import 'package:GeoGame/screens/mainscreen/leadboard.dart';
import 'package:GeoGame/screens/countrys/country.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Profiles extends StatefulWidget {
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  @override
  void initState() {
    super.initState();
    setState(() {
      _initializeGame();
    });
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
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2 || getSelectableCountryCount() == 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Ulkelerlist()),
      );
    } else if (selectedIndex == 3 || getSelectableCountryCount() == 0) {
      //aynı sayfa
    } else if (selectedIndex == 4 && getSelectableCountryCount() > 0) {
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
        title: Text(Yazi.get('navigasyonbar4')),
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
      body: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 15.0, // Daha belirgin gölge
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0), // Daha yuvarlak köşeler
        ),
        shadowColor: Colors.black.withOpacity(0.3), // Daha derin gölge
        color: Colors.grey.shade800, // Koyu, şık bir arka plan rengi
        child: Container(
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0), // Yuvarlak köşe
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade900], // Sofistike renk geçişi
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil başlığı
                  Text(
                    ('$name'),
                    style: TextStyle(
                      fontSize: 26.0, // Daha büyük başlık
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2, // Harf aralığı ekleyerek şıklık katma
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  SizedBox(height: 10.0),

                  // Kullanıcı puanı
                  Text(
                    '${Yazi.get('profil1')} $toplampuan',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10.0),

                  // Mesafe puan doğru / yanlış
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  Text(
                    '${Yazi.get('profil2')} $mesafepuan',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil3')} $mesafedogru',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil4')} $mesafeyanlis',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  // Bayrak puan doğru / yanlış
                  Text(
                    '${Yazi.get('profil5')} $bayrakpuan',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil6')} $bayrakdogru',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil7')} $bayrakyanlis',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  // Başkent puan doğru / yanlış
                  Text(
                    '${Yazi.get('profil8')} $baskentpuan',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil9')} $baskentdogru',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil10')} $baskentyanlis',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
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
