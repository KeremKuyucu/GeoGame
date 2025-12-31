import 'package:flutter/material.dart';
import 'package:geogame/widgets/drawer_widget.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/update_checker_service.dart';

// Oyun sayfaları
import 'package:geogame/screens/games/capital/capital_screen.dart';
import 'package:geogame/screens/games/flag/flag_screen.dart';
import 'package:geogame/screens/games/distance/distance_screen.dart';
import 'package:geogame/screens/games/borderline/borderline_screen.dart';
import 'package:geogame/screens/games/borderpath/borderpath_screen.dart';

import 'package:geogame/screens/settings/settings.dart';

import 'package:geogame/models/app_context.dart';




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
          'img': 'assets/images/capital.webp',
          'color': '0xFF6A1B9A', // Mor tonu
        },
        {
          'title': Localization.t('game_flag.title'),
          'desc': Localization.t('game_flag.description'),
          'img': 'assets/images/flag.webp',
          'color': '0xFF2E7D32', // Yeşil tonu
        },
        {
          'title': Localization.t('game_distance.title'),
          'desc': Localization.t('game_distance.description'),
          'img': 'assets/images/distance.webp',
          'color': '0xFF1565C0', // Mavi tonu
        },
        {
          'title': Localization.t('game_borderline.title'),
          'desc': Localization.t('game_borderline.description'),
          'img': 'assets/images/borderline.webp',
          'color': '0xFF283593',
        },
        {
          'title': Localization.t('game_borderpath.title'),
          'desc': Localization.t('game_borderpath.description'),
          'img': 'assets/images/borderpath.webp',
          'color': '0xFFD84315',
        }
  ];

  @override
  void initState() {
    super.initState();

    // Ekran çizildikten hemen sonra çalışması için:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.check(context);
    });
  }
  void _startGame(int index) {
    if (AppState.filteredCountries.isEmpty) {
      _showNoContinentWarning();
      return;
    }

    final Map<int, Widget> gamePages = {
      0: const CapitalGame(),
      1: const FlagGame(),
      2: const DistanceGame(),
      3: const BorderLineGame(),
      4: const BorderPathGame(),
    };

    final Widget? selectedPage = gamePages[index];

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // ... AppBar kodların aynı ...
        title: const Text('GEOGAME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const DrawerWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
                : [const Color(0xFFF5F7FA), const Color(0xFFC3CFE2)],
          ),
        ),
        // BURASI KRİTİK NOKTA: Ekran boyutunu dinliyoruz
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Eğer ekran genişliği 800px'den büyükse (PC/Tablet Yatay) -> GRID
            if (constraints.maxWidth > 800) {
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Yan yana 2 kutu
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.8, // Yatay dikdörtgen oranı (PC ekranına uygun)
                ),
                itemCount: data.length,
                itemBuilder: (context, index) => _buildGameCard(data[index], index, isGrid: true),
              );
            }
            // Eğer ekran darsa (Telefon) -> LISTE
            else {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                itemCount: data.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: SizedBox(
                    height: 200, // Mobilde sabit yükseklik
                    child: _buildGameCard(data[index], index, isGrid: false),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Kart tasarımını metod haline getirdik (Kod tekrarını önlemek için)
  Widget _buildGameCard(Map<String, String> item, int index, {required bool isGrid}) {
    final Color themeColor = Color(int.parse(item['color']!));

    return GestureDetector(
      onTap: () => _startGame(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(item['img']!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // İçerik
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['title']!.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isGrid ? 14 : 12, // Grid'de biraz daha büyük olabilir
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isGrid ? 32 : 26, // PC'de başlık daha büyük
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            // Grid görünümünde açıklama çok yer kaplarsa gizleyebiliriz
                            // veya PC ekranı büyük olduğu için gösterebiliriz.
                            if (!isGrid || MediaQuery.of(context).size.width > 1000) ...[
                              const SizedBox(height: 4),
                              Text(
                                item['desc']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[300], fontSize: 14),
                              ),
                            ]
                          ],
                        ),
                      ),
                      // Play Butonu
                      Container(
                        width: isGrid ? 60 : 50,
                        height: isGrid ? 60 : 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow_rounded, color: themeColor, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
