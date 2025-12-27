// lib/screens/games/baskentoyun.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Modeller
import 'package:geogame/models/app_context.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/models/countries.dart';

// Servisler
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/games/capital_service.dart';

// Widgetlar ve Sayfalar
import 'package:geogame/widgets/custom_notification.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';

class CapitalGame extends StatefulWidget {
  const CapitalGame({super.key});

  @override
  State<CapitalGame> createState() => _CapitalGameState();
}

class _CapitalGameState extends State<CapitalGame> {
  // Logic sınıfını çağırıyoruz
  final CapitalGameService _gameService = CapitalGameService();

  final TextEditingController _controller = TextEditingController();

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

    // UI kuralları gösterir
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
                Text(Localization.t('game_common.save_points_warning')),
                const SizedBox(height: 8),
                Text(Localization.t('game_capital.rule_welcome')),
                const SizedBox(height: 8),
                Text(Localization.t('game_common.score_system_generic')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Localization.t('common.ok')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkAnswer(int index) {
    String answerText = _controller.text;
    if (AppState.filter.isButtonMode && index < 4) {
      answerText = buttonLabels[index];
    }

    bool isCorrect = _gameService.processAnswer(answerText, index);

    setState(() {
      if (isCorrect) {
        _controller.clear();
      } else {
        _controller.clear();
      }
    });
  }

  void _pasButtonPressed() {
    String pasUlke = _gameService.handlePass();

    showDialog(
      context: context,
      builder: (context) {
        return CustomNotification(
            baslik: Localization.t('game_common.passed_msg'),
            metin: pasUlke
        );
      },
    );

    setState(() {
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- TEMA VE RENK AYARLARI ---
    final bool isDark = AppState.settings.darkTheme;
    final Color scaffoldBg = isDark ? const Color(0xFF121212) : Colors.grey.shade100;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color inputFill = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(Localization.t('game_capital.title')),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              // 1. SORU KARTI (Modern Görünüm)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      Localization.t('game_capital.content'),
                      style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      targetCountry.capital, // Sorulan Başkent
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. PAS BUTONU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pasButtonPressed,
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  label: Text(Localization.t('pass'), style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. OYUN ALANI (Buton veya Klavye Modu)
              if (AppState.filter.isButtonMode)
              // --- BUTON MODU ---
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildOptionButton(0, context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOptionButton(1, context)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildOptionButton(2, context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOptionButton(3, context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Localization.t('game_common.options_hint'),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                )
              else
              // --- KLAVYE MODU (AUTOCOMPLETE - KÜTÜPHANESİZ) ---
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
                    _checkAnswer(0);
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
                                      imageUrl: option.flagUrl,
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
            ],
          ),
        ),
      ),
    );
  }

  /// Buton modundaki şık butonları oluşturan yardımcı metod
  Widget _buildOptionButton(int index, BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: isButtonActive[index]
            ? () {
          _controller.text = buttonLabels[index];
          _checkAnswer(index);
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColors[index],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isButtonActive[index] ? 2 : 0,
        ),
        child: Text(
          buttonLabels[index],
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}