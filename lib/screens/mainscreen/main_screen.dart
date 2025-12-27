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
          'img': 'assets/capital.webp',
          'color': '0xFF6A1B9A', // Mor tonu
        },
        {
          'title': Localization.t('game_flag.title'),
          'desc': Localization.t('game_flag.description'),
          'img': 'assets/flag.webp',
          'color': '0xFF2E7D32', // Yeşil tonu
        },
        {
          'title': Localization.t('game_distance.title'),
          'desc': Localization.t('game_distance.description'),
          'img': 'assets/distance.webp',
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
    // Tema kontrolü (Dark/Light)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar'ı saydamlaştırıp içeriği arkasına iter
      appBar: AppBar(
        title: const Text(
          'GEOGAME',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: Colors.white, // Koyu arka planda beyaz yazı
            fontSize: 24,
            shadows: [
              Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2))
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent, // Saydam AppBar
        centerTitle: true,
      ),
      drawer: const DrawerWidget(),
      body: Container(
        // Arka plana hafif bir desen veya gradient ekleyebiliriz
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
                : [const Color(0xFFF5F7FA), const Color(0xFFC3CFE2)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20), // Üstten boşluk (AppBar için)
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final Color themeColor = Color(int.parse(item['color']!));

            return GestureDetector(
              onTap: () => _startGame(index),
              child: Container(
                height: 200, // Daha büyük, poster gibi kartlar
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(item['img']!), // Görsel arka plan oldu
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2), // Görseli hafif karart
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    // 1. Gradient Katmanı (Yazıların okunması için)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.8), // Alt kısım koyu
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),

                    // 2. İçerik (Yazılar ve Buton)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Başlık ve Açıklama
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: themeColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item['title']!.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4,
                                            color: Colors.black,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['desc']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // "Oyna" Butonu (Play Icon)
                              const SizedBox(width: 10),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: themeColor,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 3. Sağ Üst Köşe Dekoratif İkon (Opaklığı düşük)
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Icon(
                        Icons.gamepad, // Veya oyuna özel ikon
                        color: Colors.white.withOpacity(0.2),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
