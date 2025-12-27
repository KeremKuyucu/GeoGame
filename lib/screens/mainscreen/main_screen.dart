import 'package:flutter/material.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/models/countries.dart';

import 'package:geogame/services/localization_service.dart';

// Oyun sayfaları
import 'package:geogame/screens/games/capital/capital_screen.dart';
import 'package:geogame/screens/games/flag/flag_screen.dart';
import 'package:geogame/screens/games/distance/distance_screen.dart';

import 'package:geogame/screens/settings/settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// ... (Importlar aynı kalacak)

class _MainScreenState extends State<MainScreen> {
  // Getter yapısı çok doğru, dil değiştiğinde burası güncellenir.
  List<Map<String, String>> get _gameData => [
        {
          'title': Localization.t('game_capital.title'),
          'desc': Localization.t('game_capital.description'),
          'img': 'assets/baskent.jpg',
          'color': '0xFF6A1B9A', // Mor tonu
        },
        {
          'title': Localization.t('game_flag.title'),
          'desc': Localization.t('game_flag.description'),
          'img': 'assets/bayrak.jpg',
          'color': '0xFF2E7D32', // Yeşil tonu
        },
        {
          'title': Localization.t('game_distance.title'),
          'desc': Localization.t('game_distance.description'),
          'img': 'assets/mesafe.jpg',
          'color': '0xFF1565C0', // Mavi tonu
        },
      ];

  void _startGame(int index) {
    // 1. Kıta seçimi kontrolü
    if (getFilteredCountries().isEmpty) {
      _showNoContinentWarning();
      return;
    }

    // 2. Sayfa belirleme (Map kullanarak switch-case kalabalığından kurtuluyoruz)
    final Map<int, Widget> gamePages = {
      0: const CapitalGame(),
      1: const FlagGame(),
      2: const DistanceGame(),
    };

    final Widget? selectedPage = gamePages[index];

    // 3. Geçerli bir sayfa varsa yönlendir
    if (selectedPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => selectedPage),
      );
    }
  }

// SnackBar mantığını ayrı bir yere alarak ana fonksiyonu temiz tutuyoruz
  void _showNoContinentWarning() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Varsa eskisini kapat

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15), // Floating olduğu için kenarlardan boşluk
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Localization.t('settings.no_continent_active'),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: Localization.t('settings.title').toUpperCase(),
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _gameData;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GeoGame',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: const Color(0xff6200ee),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      drawer: const DrawerWidget(),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final Color categoryColor = Color(int.parse(item['color']!));

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: isDark ? Colors.grey[900] : Colors.white,
                child: InkWell(
                  onTap: () => _startGame(index),
                  splashColor: categoryColor.withOpacity(0.2),
                  child: Stack(
                    children: [
                      // Arka Plan Dekoru (Hafif bir renk dokunuşu)
                      Positioned(
                        right: -20,
                        top: -20,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: categoryColor.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Oyun Görseli
                            Hero(
                              tag: 'game_img_$index',
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(item['img']!),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: categoryColor.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Metin Alanı
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: categoryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item['desc']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: categoryColor.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
