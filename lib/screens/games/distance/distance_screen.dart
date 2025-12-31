// lib/screens/games/mesafeoyun.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';

import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/custom_notification.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/game_service.dart';

import 'package:geogame/screens/main_scaffold/main_scaffold.dart';


class DistanceGame extends StatefulWidget {
  const DistanceGame({super.key});

  @override
  State<DistanceGame> createState() => _DistanceGameState();
}

class _DistanceGameState extends State<DistanceGame> {
  final TextEditingController _controller = TextEditingController();
  final List<GuessResultModel> _guesses = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    await GameService.initializeGame(GameType.distance);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRulesDialog();
    });
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
                _buildRuleItem(Icons.save, Localization.t('game_common.save_points_warning')),
                const SizedBox(height: 10),
                _buildRuleItem(Icons.map, Localization.t('game_distance.rule_welcome')),
                const SizedBox(height: 10),
                _buildRuleItem(Icons.straighten, Localization.t('game_distance.rule_score')),
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
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Future<void> _checkAnswer() async {
    String inputText = _controller.text.trim();
    if (inputText.isEmpty) return;

    GuessResultModel? result = await GameService.processDistanceGuess(inputText);
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localization.t('game_common.not_found')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _controller.clear();
      if (result.isCorrect) {
        _showWinDialog(result.countryName);
        _guesses.clear();
      } else {
        _guesses.insert(0, result);
      }
    });
  }

  void _showWinDialog(String countryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text(Localization.t('game_common.congratulations')),
          ],
        ),
        content: Text(Localization.t('game_common.correct_msg', args: [countryName])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localization.t('common.ok'), style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Future<void> _pasButtonPressed() async {
    String passCountry = await GameService.handlePass();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => CustomNotification(
          baslik: Localization.t('game_common.passed_msg', args: [""]),
          metin: passCountry
      ),
    );
    setState(() {
      _guesses.clear();
      _controller.clear();
    });
  }

  void _clearGuesses() {
    setState(() {
      _guesses.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppState.settings.darkTheme;

    // Mavi/Okyanus Teması Gradient
    final List<Color> bgColors = isDark
        ? [const Color(0xFF0D47A1), const Color(0xFF000000)] // Derin Mavi -> Siyah
        : [const Color(0xFFE3F2FD), const Color(0xFF90CAF9)]; // Açık Mavi -> Gökyüzü

    final Color cardBg = isDark ? const Color(0xFF1E2746) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color accentColor = Colors.blueAccent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('game_distance.title'),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
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
          child: Column(
            children: [
              // 1. ÜST PANEL (INPUT & BUTONLAR)
              _buildInputDashboard(context, cardBg, textColor, accentColor, isDark),

              // 2. TAHMİN LİSTESİ
              Expanded(
                child: _guesses.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _guesses.length,
                  itemBuilder: (context, index) {
                    final guess = _guesses[index];
                    // İlk eleman en yeni tahmindir, onu biraz daha vurgulayabiliriz
                    return _buildGuessCard(guess, cardBg, textColor, index == 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildInputDashboard(BuildContext context, Color cardBg, Color textColor, Color accentColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // AUTOCOMPLETE INPUT
          Autocomplete<Country>(
            displayStringForOption: (Country option) =>
                option.getLocalizedName(Localization.currentLanguage),

            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Country>.empty();
              }
              return AppState.allCountries.where((Country ulke) {
                final String currentName = ulke.getLocalizedName(Localization.currentLanguage);
                return currentName.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },

            onSelected: (Country secilenUlke) {
              _controller.text = secilenUlke.getLocalizedName(Localization.currentLanguage);
              FocusScope.of(context).unfocus();
              _checkAnswer();
            },

            fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
              if (_controller.text.isEmpty && fieldTextEditingController.text.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  fieldTextEditingController.clear();
                });
              }
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
                  cursorColor: accentColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: Localization.t('game_common.input_hint'),
                    hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
                    prefixIcon: Icon(Icons.search, color: accentColor),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 64, // Margin payı
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                      itemBuilder: (BuildContext context, int index) {
                        final Country option = options.elementAt(index);
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.black.withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                            child: FutureBuilder<Widget>(
                              future: _loadOptionFlag(option.iso2, option.flagUrl),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                } else if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else {
                                  return const Icon(Icons.flag);
                                }
                              },
                            ),
                          ),
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
          ),

          const SizedBox(height: 16),

          // AKSİYON BUTONLARI
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pasButtonPressed,
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: Text(Localization.t('common.pass')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearGuesses,
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: Text(Localization.t('game_common.clear_guesses')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Widget> _loadOptionFlag(String iso2, String url) async {
    final assetPath = 'assets/flags/${iso2.toLowerCase()}.webp';
    bool exists = false;

    try {
      // WebP bir resim olduğu için loadString değil, doğrudan load (ByteData) kullanılır.
      // Ancak en hızlı kontrol yolu AssetManifest'tir.
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      exists = manifestMap.containsKey(assetPath);
    } catch (_) {
      exists = false;
    }

    if (exists) {
      return ClipOval(
        child: Image.asset(
          assetPath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          // Beklenmedik bir durumda asset yüklenemezse network'e düş
          errorBuilder: (context, error, stackTrace) => _networkImage(url),
        ),
      );
    } else {
      return _networkImage(url);
    }
  }

  // Kod tekrarını önlemek için yardımcı fonksiyon
  Widget _networkImage(String url) {
    return ClipOval(
      child: Image.network(
        url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 24),
      ),
    );
  }


  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 100,
            color: isDark ? Colors.white24 : Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            Localization.t('game_common.first_guess'),
            style: TextStyle(
                color: isDark ? Colors.white54 : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessCard(GuessResultModel guess, Color cardBg, Color textColor, bool isFirst) {
    const double maxDist = 15000.0;
    // Mesafe oranı (0: Çok yakın, 1: Çok uzak)
    final double ratio = (guess.distanceKm / maxDist).clamp(0.0, 1.0);
    // Renk: Yakınsa Yeşil, Uzaksa Kırmızı
    final Color distanceColor = Color.lerp(Colors.greenAccent.shade700, Colors.redAccent, ratio)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: isFirst ? Border.all(color: distanceColor.withValues(alpha: 0.5), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // SOL: Ülke İsmi ve Mesafe Çubuğu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guess.countryName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Mesafe Göstergesi
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: distanceColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.straighten, size: 14, color: distanceColor),
                            const SizedBox(width: 6),
                            Text(
                              "${guess.distanceKm.toInt()} km",
                              style: TextStyle(
                                  color: distanceColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SAĞ: Yön Oku ve Yön Metni
            Column(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppState.settings.darkTheme ? Colors.black26 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    angle: guess.bearing * (math.pi / 180),
                    child: Icon(
                      Icons.navigation,
                      size: 24,
                      color: distanceColor, // Ok rengi de mesafeye göre değişsin
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guess.directionText,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}