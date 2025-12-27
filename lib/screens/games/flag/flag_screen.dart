// lib/screens/games/flag/flag_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Modeller
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/widgets/drawer_widget.dart';

// Servisler
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/games/flag_service.dart';

// Widgetlar
import 'package:geogame/widgets/custom_notification.dart';
import 'package:geogame/screens/main_scaffold/main_scaffold.dart';

class FlagGame extends StatefulWidget {
  const FlagGame({super.key});

  @override
  State<FlagGame> createState() => _FlagGameState();
}

class _FlagGameState extends State<FlagGame> {
  // Logic sınıfını çağırıyoruz
  final FlagGameService _gameService = FlagGameService();

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
                Text(Localization.t('game_flag.rule_welcome')),
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
        // Doğru bildiyse görsel bir geri bildirim eklenebilir (SnackBar vs.)
      } else {
        _controller.clear();
        // Yanlış bildiyse buton pasifleşir (Logic serviste halledildi)
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
        title: Text(Localization.t('game_flag.title')),
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

              // 1. BAYRAK KARTI (Modern Görünüm)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 250), // Çok uzamasın
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
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: targetCountry.flagUrl,
                    fit: BoxFit.contain,
                    // Yüklenirken
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    // Hata çıkarsa
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.red.shade300),
                        const Text('Hata', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. PAS BUTONU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pasButtonPressed,
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  label: Text(Localization.t('common.pass'), style: const TextStyle(fontSize: 16)),
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
                    // Grid yapısı yerine Row/Column kombini ile daha kontrollü yerleşim
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
                  // 1. Ekranda görünecek metin (Seçili dile göre otomatik)
                  displayStringForOption: (Country option) =>
                      option.getLocalizedName(Localization.currentLanguage),

                  // 2. Arama Mantığı
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Country>.empty();
                    }
                    return allCountries.where((Country ulke) {
                      // Aramayı o anki dildeki ismine göre yap
                      final String isim = ulke.getLocalizedName(Localization.currentLanguage);
                      return isim.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },

                  // 3. Seçim Yapılınca
                  onSelected: (Country secilenUlke) {
                    _controller.text = secilenUlke.getLocalizedName(Localization.currentLanguage);
                    FocusScope.of(context).unfocus();
                    _checkAnswer(4); // Senin kodundaki checkAnswer çağrısı
                  },

                  // 4. TextField Tasarımı
                  fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                    // Controller senkronizasyonu
                    if (_controller.text.isEmpty && fieldTextEditingController.text.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        fieldTextEditingController.clear();
                      });
                    }

                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        // Hint text'i de yerelleştirmek istersen Localization.t kullanabilirsin
                        // Şimdilik eski kodundaki gibi statik bırakıyorsan değiştirebilirsin
                        hintText: Localization.t('game_common.input_hint'),
                        hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
                        prefixIcon: Icon(Icons.flag, color: isDark ? Colors.white70 : Colors.grey),
                        filled: true,
                        fillColor: inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    );
                  },

                  // 5. Liste Tasarımı (BAYRAKSIZ)
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32, // Padding payı
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                            itemBuilder: (BuildContext context, int index) {
                              final Country option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                // Leading (Resim/Bayrak) alanı YOK
                                title: Text(
                                  // Listede görünen isim
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
      height: 60, // Buton yüksekliğini sabitledik
      child: ElevatedButton(
        onPressed: isButtonActive[index]
            ? () {
          _controller.text = buttonLabels[index];
          _checkAnswer(index);
        }
            : null, // Tıklanamaz ise (yanlışsa) disabled olur
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
            color: Colors.black87, // Buton rengine göre okunabilir renk
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}