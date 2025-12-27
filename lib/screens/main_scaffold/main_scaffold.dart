import 'package:flutter/material.dart';

// 1. Modeller ve Servisler
import 'package:geogame/models/app_context.dart';

import 'package:geogame/widgets/custom_navbar.dart';

import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leadboards-and-profile/leadboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';
import 'package:geogame/screens/settings/settings.dart';


class AnaIskelet extends StatefulWidget {
  const AnaIskelet({super.key});

  @override
  State<AnaIskelet> createState() => _AnaIskeletState();
}

class _AnaIskeletState extends State<AnaIskelet> {
  // Sayfaları bir liste olarak tanımlıyoruz.
  // const kullanarak performans artışı sağlıyoruz.
  final List<Widget> _sayfalar = [
     MainScreen(),    // Index 0: Oyunlar
     Leadboard(),     // Index 1: Sıralama
     Profiles(),      // Index 2: Profil
     SettingsPage(),  // Index 3: Ayarlar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BODY KISMI:
      // IndexedStack kullanıyoruz. Bu sayede sekmeler arası gezerken
      // sayfaların durumu (scroll yeri, yazılan yazılar vb.) kaybolmaz.
      body: IndexedStack(
        index: AppState.selectedIndex, // Global değişkeni dinliyoruz
        children: _sayfalar,
      ),

      // NAVBAR KISMI:
      // Senin hazırladığın CustomNavBar'ı buraya koyuyoruz.
      bottomNavigationBar: CustomNavBar(
        // Navbar'a "Şu an hangi sıradayız?" bilgisini veriyoruz
        currentIndex: AppState.selectedIndex,

        // Navbar'a tıklandığında ne olacağını söylüyoruz
        onTap: (index) {
          setState(() {
            // Hem ekranı güncelliyoruz hem de global değişkeni
            AppState.selectedIndex = index;
          });
        },
      ),
    );
  }
}