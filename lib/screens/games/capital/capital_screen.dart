// lib/screens/games/baskentoyun.dart

import 'package:flutter/material.dart';

// Modeller
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/models/countries.dart';

// Servisler
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/game_service.dart';

// Widgetlar ve Sayfalar
import 'package:geogame/widgets/custom_notification.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/flag_loader.dart';

class CapitalGame extends StatefulWidget {
  const CapitalGame({super.key});

  @override
  State<CapitalGame> createState() => _CapitalGameState();
}

class _CapitalGameState extends State<CapitalGame> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Soru değiştiğinde animasyon için
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüsü
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    await GameService.initializeGame(GameType.capital);
    _animController.forward(from: 0.0); // İlk animasyonu tetikle

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
                _buildRuleItem(Icons.info_outline, Localization.t('game_capital.rule_welcome')),
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
        Icon(icon, size: 20, color: Colors.deepPurple),
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

    bool isCorrect = await GameService.checkStandardAnswer(answer, GameType.flag, index);

    setState(() {
      if (isCorrect) {
        _controller.clear();
        _animController.forward(from: 0.0); // Yeni soru için animasyonu sıfırla
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
      _animController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- TEMA VE RENK AYARLARI ---
    final bool isDark = AppState.settings.darkTheme;

    // Arka plan gradient renkleri
    final List<Color> bgColors = isDark
        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
        : [const Color(0xFFEDE7F6), const Color(0xFFD1C4E9)];

    final Color cardBg = isDark ? const Color(0xFF252538) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color accentColor = const Color(0xFF673AB7); // Deep Purple

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('game_capital.title'),
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                    (route) => false,
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

                  // 1. SORU KARTI (Modern Tasarım)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.location_city, size: 40, color: accentColor),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            Localization.t('game_capital.content'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppState.targetCountry.capital, // Sorulan Başkent
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 2. OYUN ALANI (Klavye veya Buton)
                  if (AppState.filter.isButtonMode)
                    _buildButtonModeUI(context)
                  else
                    _buildKeyboardModeUI(context, cardBg, textColor, accentColor),

                  const SizedBox(height: 30),

                  // 3. PAS BUTONU (Alta alındı, daha temiz görünüm)
                  TextButton.icon(
                    onPressed: _pasButtonPressed,
                    icon: Icon(Icons.skip_next, color: isDark ? Colors.white70 : Colors.grey.shade700),
                    label: Text(
                        Localization.t('common.pass'),
                        style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
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
        const SizedBox(height: 20),
        Text(
          Localization.t('game_common.options_hint'),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
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
              _checkAnswer(0);
            },

            fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
              if (_controller.text.isEmpty && fieldTextEditingController.text.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  fieldTextEditingController.clear();
                });
              }
              return Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
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
                    prefixIcon: Icon(Icons.search, color: accentColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    width: constraints.maxWidth, // Klavye genişliğine eşitle
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
                            child: FlagWidget(
                              iso2: option.iso2,
                              flagUrl: option.flagUrl,
                              size: 40,
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
          );
        }
    );
  }


  Widget _buildOptionButton(int index, BuildContext context) {
    return SizedBox(
      height: 70, // Biraz daha yüksek
      child: ElevatedButton(
        onPressed: AppState.buttons[index].isActive
            ? () {
          _controller.text = AppState.buttons[index].label;
          _checkAnswer(index);
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppState.buttons[index].color,
          foregroundColor: Colors.white, // Yazı rengi her zaman beyaz (okunurluk için)
          elevation: AppState.buttons[index].isActive ? 4 : 0,
          shadowColor: AppState.buttons[index].color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          AppState.buttons[index].label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}