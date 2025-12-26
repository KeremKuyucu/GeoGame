import 'package:flutter/material.dart';
import 'package:theme_mode_builder/common/theme_mode_builder_config.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/bottomBar.dart';
import 'package:geogame/models/drawer_widget.dart';
import 'package:geogame/models/countries.dart';

import 'package:geogame/services/localization_service.dart';

import 'package:geogame/screens/settings/settings.dart';
import 'package:geogame/screens/leadboards-and-profile/leadboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';

import 'package:geogame/screens/games/baskentoyun.dart';
import 'package:geogame/screens/games/bayrakoyun.dart';
import 'package:geogame/screens/games/mesafeoyun.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedOption = 0;

  @override
  void initState() {
    super.initState();
    if (AppState.settings.darkTheme)
      ThemeModeBuilderConfig.setDark();
    else
      ThemeModeBuilderConfig.setLight();
  }

  void _selectOption(int index) async {
    setState(() {
      _selectedOption = index;
    });
    if (_selectedOption == 0 && getFilteredCountries().length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BaskentOyun()),
      );
    } else if (_selectedOption == 1 && getFilteredCountries().length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BayrakOyun()),
      );
    } else if (_selectedOption == 2 && getFilteredCountries().length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MesafeOyun()),
      );
    } else if (getFilteredCountries().length < 1) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            // Listelerle yapılandırma
            final titles = [
              Localization.get('baskenttitle'),
              Localization.get('bayraktitle'),
              Localization.get('mesafetitle'),
            ];

            final descriptions = [
              Localization.get('baskentdescription'),
              Localization.get('bayrakdescription'),
              Localization.get('mesafedescription'),
            ];

            final images = [
              'assets/baskent.jpg',
              'assets/bayrak.jpg',
              'assets/mesafe.jpg',
            ];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  _selectOption(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          images[index],
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
                              titles[index],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              descriptions[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
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
      drawer: DrawerWidget(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: AppState.selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        items: navBarItems,

        // ✅ Tüm mantık burada
        onTap: (index) {
          // 1. Zaten aynı sayfadaysak HİÇBİR ŞEY YAPMA (Buradan çık)
          if (AppState.selectedIndex == index) return;

          // 2. Değilsek, seçili indexi güncelle (Rengi değiştirir)
          setState(() {
            AppState.selectedIndex = index;
          });

          // 3. Hangi sayfaya gidileceğini belirle
          Widget page;
          switch (index) {
            case 0:
              page = MainScreen();
              break;
            case 1:
              page = Leadboard();
              break;
            case 2:
              page = Profiles();
              break;
            case 3:
              page = SettingsPage();
              break;
            default:
              return;
          }

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => page,
              transitionDuration: Duration.zero, // Anında geçiş
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }
}
