import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
// Sayfalarını import et
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leadboards-and-profile/leadboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings.dart';
import 'package:geogame/services/localization_service.dart';

class AnaIskelet extends StatefulWidget {
  const AnaIskelet({super.key});

  @override
  State<AnaIskelet> createState() => _AnaIskeletState();
}

class _AnaIskeletState extends State<AnaIskelet> {
  int _currentIndex = 0;

  final List<Widget> _sayfalar = [
    MainScreen(),
    Leadboard(),
    Profiles(),
    SettingsPage(),
  ];

  List<SalomonBottomBarItem> get _navBarItems => [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home),
      title: Text(Localization.get('navigasyonbar1')),
      selectedColor: const Color(0xff6200ee),
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.leaderboard),
      title: Text(Localization.get('navigasyonbar2')),
      selectedColor: Colors.pink,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.person),
      title: Text(Localization.get('navigasyonbar3')),
      selectedColor: Colors.teal,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.settings),
      title: Text(Localization.get('navigasyonbar4')),
      selectedColor: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _sayfalar,
      ),

      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),

        // Items'ı getter olarak çağırıyoruz
        items: _navBarItems,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Eğer AppState kullanmaya devam edeceksen burayı da güncelle:
            // AppState.selectedIndex = index;
          });
        },
      ),
    );
  }
}