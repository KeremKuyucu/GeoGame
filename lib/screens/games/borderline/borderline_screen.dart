// lib/screens/games/borderline/borderline_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Modeller
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/widgets/drawer_widget.dart';

// Servisler
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/game_service.dart';

// Widgetlar
import 'package:geogame/widgets/custom_notification.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';

class BorderLineGame extends StatefulWidget {
  const BorderLineGame({super.key});

  @override
  State<BorderLineGame> createState() => _BorderLineGameState();
}

class _BorderLineGameState extends State<BorderLineGame> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Animasyon
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  // GeoJSON Path verisi (Çizim için)
  Future<Path?>? _countryShapePathFuture;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);

    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    // Oyun mantığını başlat (Ülkeyi seçer)
    await GameService.initializeGame(GameType.borderline); // GameType.borderline enum'ına eklediğini varsayıyorum

    // Seçilen ülkeye göre path oluşturma işlemini başlat
    setState(() {
      _countryShapePathFuture = _loadAndParseGeoJson(AppState.targetCountry.iso3);
    });

    _animController.forward(from: 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRulesDialog();
    });
  }

  /// GeoJSON dosyasını okuyip Flutter Path nesnesine çeviren kritik fonksiyon
  Future<Path?> _loadAndParseGeoJson(String isoCode) async {
    try {
      final String pathString = 'assets/data/$isoCode.geo.json';
      final String jsonString = await rootBundle.loadString(pathString);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final Path path = Path();

      // GeoJSON FeatureCollection veya Feature yapısını kontrol et
      List features = [];
      if (jsonData['type'] == 'FeatureCollection') {
        features = jsonData['features'];
      } else if (jsonData['type'] == 'Feature') {
        features = [jsonData];
      }

      for (var feature in features) {
        final geometry = feature['geometry'];
        final String type = geometry['type'];
        final List coordinates = geometry['coordinates'];

        if (type == 'Polygon') {
          _addPolygonToPath(path, coordinates);
        } else if (type == 'MultiPolygon') {
          for (var polygonCoords in coordinates) {
            _addPolygonToPath(path, polygonCoords);
          }
        }
      }
      return path;
    } catch (e) {
      debugPrint("GeoJSON Parse Hatası ($isoCode): $e");
      return null; // Dosya yoksa veya bozuksa null döner
    }
  }

  /// Koordinat listesini Path'e ekleyen yardımcı metod
  void _addPolygonToPath(Path path, List polygonCoords) {
    // GeoJSON'da ilk array dış halkadır (outer ring), sonrakiler deliklerdir (holes).
    // Basitlik adına sadece dış halkayı çiziyoruz veya hepsini addPolygon yapıyoruz.
    for (var ring in polygonCoords) {
      if (ring.isEmpty) continue;

      // İlk nokta
      // GeoJSON: [Longitude(x), Latitude(y)]
      // Ekran Koordinatı: Y ekseni aşağı arttığı için Latitude'u ters çeviriyoruz (-y).
      double startX = (ring[0][0] as num).toDouble();
      double startY = -(ring[0][1] as num).toDouble();

      path.moveTo(startX, startY);

      for (int i = 1; i < ring.length; i++) {
        double x = (ring[i][0] as num).toDouble();
        double y = -(ring[i][1] as num).toDouble();
        path.lineTo(x, y);
      }
      path.close();
    }
  }

  Future<void> _showRulesDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(Localization.t('game_common.rules')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildRuleItem(Icons.public, Localization.t('game_borderline.rule_welcome')), // "Şekilden ülkeyi tanı"
                const SizedBox(height: 10),
                _buildRuleItem(Icons.zoom_in, Localization.t('game_borderline.hint_scale')), // "Şekiller ölçeklidir"
                const SizedBox(height: 10),
                _buildRuleItem(Icons.star_border, Localization.t('game_common.score_system_generic')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Localization.t('common.ok'), style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRuleItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Future<void> _checkAnswer(int index) async {
    String answer = _controller.text;
    if (AppState.filter.isButtonMode && index < 4) {
      answer = AppState.buttons[index].label;
    }

    // Enum GameType.borderline olmalı
    bool isCorrect = await GameService.checkStandardAnswer(answer, GameType.borderline, index);

    setState(() {
      if (isCorrect) {
        _controller.clear();
        _countryShapePathFuture = _loadAndParseGeoJson(AppState.targetCountry.iso3);
        _animController.forward(from: 0.0);
      } else {
        _controller.clear();
      }
    });
  }

  Future<void> _pasButtonPressed() async {
    String passCountry = await GameService.handlePass();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return CustomNotification(
            baslik: Localization.t('game_common.passed_msg'),
            metin: passCountry
        );
      },
    );

    setState(() {
      _controller.clear();
      _countryShapePathFuture = _loadAndParseGeoJson(AppState.targetCountry.iso3);
      _animController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppState.settings.darkTheme;

    // Şekil oyunu için Mavi/Indigo Tema
    final List<Color> bgColors = isDark
        ? [const Color(0xFF1A237E), const Color(0xFF000000)] // Koyu Indigo - Siyah
        : [const Color(0xFFE8EAF6), const Color(0xFF9FA8DA)]; // Açık Indigo

    final Color cardBg = isDark ? const Color(0xFF283593).withValues(alpha: 0.5) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color accentColor = const Color(0xFF536DFE); // Indigo Accent

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('game_borderline.title'), // "Harita Oyunu"
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              GameLogService.syncPendingLogs();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScaffold()),
              );
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  // 1. HARİTA/ŞEKİL ALANI
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 300, // Harita için daha geniş alan
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isDark ? Colors.white10 : Colors.indigo.withValues(alpha: 0.1),
                            width: 2
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: FutureBuilder<Path?>(
                        future: _countryShapePathFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(color: accentColor),
                            );
                          }
                          if (snapshot.hasError || snapshot.data == null) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50, color: isDark ? Colors.white38 : Colors.grey),
                                const SizedBox(height: 10),
                                Text(
                                  "Harita verisi yüklenemedi",
                                  style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                                ),
                                if (snapshot.hasError)
                                  Text(
                                    snapshot.error.toString(),
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                  )
                              ],
                            );
                          }

                          // BAŞARILI: CustomPaint ile Path çizdirme
                          return CustomPaint(
                            painter: CountryShapePainter(
                              path: snapshot.data!,
                              color: isDark ? const Color(0xFFC5CAE9) : const Color(0xFF3949AB),
                              strokeColor: isDark ? Colors.white : Colors.black87,
                            ),
                            child: Container(),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 2. OYUN BUTONLARI / INPUT
                  if (AppState.filter.isButtonMode)
                    _buildButtonModeUI(context)
                  else
                    _buildKeyboardModeUI(context, cardBg, textColor, accentColor),

                  const SizedBox(height: 20),

                  // 3. PAS BUTONU
                  TextButton.icon(
                    onPressed: _pasButtonPressed,
                    icon: Icon(Icons.skip_next, color: isDark ? Colors.white70 : Colors.indigo.shade900),
                    label: Text(
                        Localization.t('common.pass'),
                        style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.indigo.shade900,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildButtonModeUI(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildOptionButton(0, context)),
            const SizedBox(width: 15),
            Expanded(child: _buildOptionButton(1, context)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildOptionButton(2, context)),
            const SizedBox(width: 15),
            Expanded(child: _buildOptionButton(3, context)),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(int index, BuildContext context) {
    // Shape game için buton renklerini override etmek isteyebilirsin
    // veya AppState'deki global renkleri kullanabilirsin.
    return SizedBox(
      height: 65,
      child: ElevatedButton(
        onPressed: AppState.buttons[index].isActive
            ? () {
          _controller.text = AppState.buttons[index].label;
          _checkAnswer(index);
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppState.buttons[index].color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: AppState.buttons[index].isActive ? 5 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        child: Text(
          AppState.buttons[index].label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildKeyboardModeUI(BuildContext context, Color cardBg, Color textColor, Color accentColor) {
    final bool isDark = AppState.settings.darkTheme;

    return LayoutBuilder(
        builder: (context, constraints) {
          return Autocomplete<Country>(
            displayStringForOption: (Country option) =>
                option.getLocalizedName(Localization.currentLanguage),

            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<Country>.empty();
              return AppState.allCountries.where((Country ulke) {
                final String isim = ulke.getLocalizedName(Localization.currentLanguage);
                return isim.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },

            onSelected: (Country secilenUlke) {
              _controller.text = secilenUlke.getLocalizedName(Localization.currentLanguage);
              FocusScope.of(context).unfocus();
              _checkAnswer(4);
            },

            fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
              if (_controller.text.isEmpty && fieldTextEditingController.text.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) => fieldTextEditingController.clear());
              }
              return Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500),
                  cursorColor: accentColor,
                  decoration: InputDecoration(
                    hintText: Localization.t('game_common.input_hint'),
                    hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade400),
                    prefixIcon: Icon(Icons.map, color: accentColor), // İkon Map yapıldı
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              );
            },

            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8.0,
                  color: cardBg,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: constraints.maxWidth,
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                      itemBuilder: (context, index) {
                        final Country option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(
                            option.getLocalizedName(Localization.currentLanguage),
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
    );
  }
}

/// --- Custom Painter: Path'i Ekrana Oranlayarak Çizer ---
class CountryShapePainter extends CustomPainter {
  final Path path;
  final Color color;
  final Color strokeColor;

  CountryShapePainter({
    required this.path,
    required this.color,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.getBounds().isEmpty) return;

    // 1. Path'in sınırlarını (Bounding Box) bul
    final Rect bounds = path.getBounds();

    // 2. Ölçekleme faktörünü hesapla (Contain modunda sığdırma)
    // Şeklin genişliği veya yüksekliğinden hangisi daha büyükse ona göre oranla.
    final double scaleX = size.width / bounds.width;
    final double scaleY = size.height / bounds.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // 3. Matris dönüşümleri (Shift ve Scale)
    // Önce şekli (0,0) noktasına taşı (-bounds.left, -bounds.top)
    // Sonra ölçekle
    // Sonra canvas'ın ortasına hizala
    final Matrix4 matrix = Matrix4.identity();

    // Ekranda ortalamak için offset hesapla
    final double offsetX = (size.width - (bounds.width * scale)) / 2;
    final double offsetY = (size.height - (bounds.height * scale)) / 2;

    matrix.translate(offsetX, offsetY);
    matrix.scale(scale, scale);
    matrix.translate(-bounds.left, -bounds.top);

    // 4. Dönüştürülmüş path'i oluştur
    final Path transformedPath = path.transform(matrix.storage);

    // 5. Çizim
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    // Gölge efekti (Opsiyonel)
    canvas.drawShadow(transformedPath, Colors.black, 4.0, true);

    canvas.drawPath(transformedPath, fillPaint);
    canvas.drawPath(transformedPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CountryShapePainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}