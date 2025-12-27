// lib/screens/games/mesafeoyun.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/custom_notification.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';

import 'package:geogame/services/games/distance_service.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';

class DistanceGame extends StatefulWidget {
  const DistanceGame({super.key});

  @override
  State<DistanceGame> createState() => _DistanceGameState();
}

class _DistanceGameState extends State<DistanceGame> {
  final DistanceGameService _gameService = DistanceGameService();
  final TextEditingController _controller = TextEditingController();
  final List<GuessResultModel> _guesses = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    _gameService.initializeGame();
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
          title: Text(Localization.t('game_common.rules')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Localization.t('game_common.rule_save')),
                const SizedBox(height: 8),
                Text(Localization.t('game_distance.rule_desc')), // JSON'a mesafekural2 yerine eklendi
                const SizedBox(height: 8),
                Text(Localization.t('game_distance.rule_score')), // JSON'a mesafekural3 yerine eklendi
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Localization.t('common.ok')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _checkAnswer() {
    String girilenMetin = _controller.text.trim();
    if (girilenMetin.isEmpty) return;

    GuessResultModel? result = _gameService.processGuess(girilenMetin);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Localization.t('game_common.not_found'))),
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
        title: Text(Localization.t('game_common.congratulations')),
        content: Text(Localization.t('game_common.correct_msg', args: [countryName])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localization.t('common.ok')),
          )
        ],
      ),
    );
  }

  void _pasButtonPressed() {
    String pasUlke = _gameService.handlePass();
    showDialog(
      context: context,
      builder: (context) => CustomNotification(
          baslik: Localization.t('game_common.passed_msg', args: [""]), // Başlık için "Geçilen Ülke"
          metin: pasUlke
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
    final Color scaffoldBg = isDark ? const Color(0xFF121212) : Colors.grey.shade100;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputFill = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(Localization.t('game_distance.title')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 4,
                )
              ],
            ),
            child: Column(
              children: [
                Autocomplete<Country>(
                  // 1. Görüntülenecek metin (Seçili dil neyse o gelir)
                  displayStringForOption: (Country option) =>
                      option.getLocalizedName(Localization.currentLanguage),

                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Country>.empty();
                    }
                    return allCountries.where((Country ulke) {
                      // 2. Arama yaparken o anki dildeki ismine bakıyoruz
                      final String currentName = ulke.getLocalizedName(Localization.currentLanguage);

                      // İstersen hem kendi dilinde hem İngilizce isminde aratabilirsin.
                      // Şimdilik sadece görünen isme göre filtreliyorum:
                      return currentName.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },

                  onSelected: (Country secilenUlke) {
                    // 3. Seçilince inputa o dildeki ismini yaz
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
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: Localization.t('game_common.input_hint'),
                        hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.grey),
                        filled: true,
                        fillColor: inputFill,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                    );
                  },

                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32,
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Country option = options.elementAt(index);
                              return ListTile(
                                leading: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: option.flagUrl, // DİKKAT: 'url' yerine 'flagUrl' oldu
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) => Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade300,
                                          size: 18
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  // 4. Listede gösterirken de dinamik isim
                                  option.getLocalizedName(Localization.currentLanguage),
                                  style: TextStyle(color: textColor),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pasButtonPressed,
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        label: Text(Localization.t('common.pass')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearGuesses,
                        icon: const Icon(Icons.delete_sweep, color: Colors.white),
                        label: Text(Localization.t('game_common.clear_guesses')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _guesses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.public,
                      size: 80,
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Localization.t('game_common.first_guess'),
                    style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        fontSize: 16
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _guesses.length,
              itemBuilder: (context, index) {
                final guess = _guesses[index];
                return _buildGuessCard(guess, cardBg, textColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessCard(GuessResultModel guess, Color cardBg, Color textColor) {
    const double maxDist = 20000.0;
    final double ratio = (guess.distanceKm / maxDist).clamp(0.0, 1.0);
    final Color distanceColor = Color.lerp(Colors.green, Colors.red, ratio)!;

    return Card(
      color: cardBg,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guess.countryName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.straighten, size: 16, color: distanceColor),
                      const SizedBox(width: 4),
                      Text(
                        "${guess.distanceKm.toInt()} km",
                        style: TextStyle(
                            color: distanceColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Transform.rotate(
                    angle: guess.bearing * (math.pi / 180),
                    child: Icon(
                      Icons.navigation,
                      size: 30,
                      color: AppState.settings.darkTheme ? Colors.grey.shade400 : Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guess.directionText,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
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