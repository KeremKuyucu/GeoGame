// lib/screens/games/flag/flag_screen.dart

import 'package:flutter/material.dart';

// Modeller
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game_metadata.dart';

// Servisler
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/game_service.dart';

// Widgetlar
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/custom_notification.dart';
import 'package:geogame/widgets/flag_loader.dart';

class FlagGame extends StatefulWidget {
  const FlagGame({super.key});

  @override
  State<FlagGame> createState() => _FlagGameState();
}

class _FlagGameState extends State<FlagGame> with SingleTickerProviderStateMixin {
  // Logic sınıfını çağırıyoruz
  final TextEditingController _controller = TextEditingController();

  // Animasyon Kontrolcüleri
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon tanımları
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);

    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    await GameService.initializeGame(GameType.flag);
    _animController.forward(from: 0.0); // İlk animasyonu başlat

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(Localization.t('game_common.rules')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildRuleItem(Icons.save, Localization.t('game_common.save_points_warning')),
                const SizedBox(height: 10),
                _buildRuleItem(Icons.flag, Localization.t('game_flag.rule_welcome')),
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
        Icon(icon, size: 20, color: Colors.teal),
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
      _animController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {

    // Yeşil/Teal Gradient (Bayrak teması için)
    final List<Color> bgColors = AppState.settings.darkTheme
        ? [const Color(0xFF004D40), const Color(0xFF00251A)] // Koyu Yeşil
        : [const Color(0xFFE0F2F1), const Color(0xFF80CBC4)]; // Açık Yeşil

    final Color cardBg = AppState.settings.darkTheme ? const Color(0xFF263238) : Colors.white;
    final Color textColor = AppState.settings.darkTheme ? Colors.white : Colors.black87;
    final Color accentColor = const Color(0xFF009688); // Teal Accent

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Localization.t('game_flag.title'),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
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

                  // 1. BAYRAK KARTI (Modern Görünüm & Animasyonlu)
                  ScaleTransition(
                    scale: _fadeAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      height: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FutureBuilder<bool>(
                          future: FlagLoader.checkFlagAsset(AppState.targetCountry.iso2),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 250,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final bool exists = snapshot.data ?? false;

                            return FlagLoader.buildFlagImage(
                              existsLocally: exists,
                              iso2: AppState.targetCountry.iso2,
                              url: AppState.targetCountry.flagUrl,
                              height: 250,
                            );
                          },
                        )
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 2. OYUN ALANI
                  if (AppState.filter.isButtonMode)
                    _buildButtonModeUI(context)
                  else
                    _buildKeyboardModeUI(context, cardBg, textColor, accentColor),

                  const SizedBox(height: 20),

                  // 3. PAS BUTONU
                  TextButton.icon(
                    onPressed: _pasButtonPressed,
                    icon: Icon(Icons.skip_next, color: AppState.settings.darkTheme ? Colors.white70 : Colors.teal.shade900),
                    label: Text(
                        Localization.t('common.pass'),
                        style: TextStyle(
                            fontSize: 16,
                            color: AppState.settings.darkTheme ? Colors.white70 : Colors.teal.shade900,
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
        const SizedBox(height: 16),
        Text(
          Localization.t('game_common.options_hint'),
          style: TextStyle(color: Colors.white70, fontSize: 12, shadows: [Shadow(blurRadius: 2, color: Colors.black45)]),
        ),
      ],
    );
  }

  Widget _buildKeyboardModeUI(BuildContext context, Color cardBg, Color textColor, Color accentColor) {

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
                      color: Colors.black.withValues(alpha: 0.1),
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
                    hintStyle: TextStyle(color: AppState.settings.darkTheme ? Colors.grey : Colors.grey.shade400),
                    prefixIcon: Icon(Icons.flag, color: accentColor),
                    filled: true,
                    fillColor: Colors.transparent, // Container rengini kullan
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
                      itemBuilder: (BuildContext context, int index) {
                        final Country option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          // İstediğin gibi: Listede bayrak YOK
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
          foregroundColor: Colors.white, // Yazılar beyaz
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: AppState.buttons[index].isActive ? 5 : 0,
          shadowColor: AppState.buttons[index].color.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        child: Text(
          AppState.buttons[index].label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}