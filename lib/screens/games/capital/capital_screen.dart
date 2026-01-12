import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/game_widgets.dart';

import 'capital_controller.dart';

class CapitalGame extends StatefulWidget {
  const CapitalGame({super.key});

  @override
  State<CapitalGame> createState() => _CapitalGameState();
}

class _CapitalGameState extends State<CapitalGame>
    with SingleTickerProviderStateMixin {
  final CapitalGameController _controller = CapitalGameController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    await _controller.initializeGame();
    _animController.forward(from: 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGameRulesDialog(context: context, rules: _controller.getRules());
    });
  }

  Future<void> _checkAnswer(int index) async {
    bool isCorrect = await _controller.checkAnswer(index);
    setState(() {
      if (isCorrect) {
        _animController.forward(from: 0.0);
      }
    });
  }

  Future<void> _handlePass() async {
    String passCountry = await _controller.handlePass();
    if (!mounted) return;
    _controller.showPassDialog(context, passCountry);
    setState(() {
      _animController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: Localization.t('game_capital.title'),
      backgroundColors: _controller.getBackgroundColors(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Soru kartı
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: _controller.cardBg,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _controller.accentColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: _controller.accentColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _controller.accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_city,
                          size: 40,
                          color: _controller.accentColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        Localization.t('game_capital.content'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _controller.isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _controller.targetCapital,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: _controller.textColor,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Oyun alanı
              if (_controller.isButtonMode)
                GameButtonModeUI(onButtonPressed: _checkAnswer)
              else
                GameKeyboardModeUI(
                  controller: _controller.textController,
                  cardBg: _controller.cardBg,
                  textColor: _controller.textColor,
                  accentColor: _controller.accentColor,
                  prefixIcon: Icons.search,
                  showFlagInOptions: true,
                  onCountrySelected: (Country selected) => _checkAnswer(0),
                ),

              const SizedBox(height: 30),

              // Pas butonu
              GamePassButton(onPressed: _handlePass),
            ],
          ),
        ),
      ),
    );
  }
}
