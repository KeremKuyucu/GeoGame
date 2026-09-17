import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/coat_of_arms_loader.dart';
import 'package:geogame/widgets/game_widgets.dart';

import 'package:geogame/screens/games/coat_of_arms/coat_of_arms_controller.dart';

class CoatOfArmsGame extends StatefulWidget {
  const CoatOfArmsGame({super.key});

  @override
  State<CoatOfArmsGame> createState() => _CoatOfArmsGameState();
}

class _CoatOfArmsGameState extends State<CoatOfArmsGame>
    with SingleTickerProviderStateMixin {
  final CoatOfArmsGameController _controller = CoatOfArmsGameController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);

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
  }

  Future<void> _checkAnswer(int index) async {
    final isCorrect = await _controller.checkAnswer(index);
    setState(() {
      if (isCorrect) {
        _animController.forward(from: 0.0);
      }
    });
  }

  Future<void> _handlePass() async {
    final passCountry = await _controller.handlePass();
    if (!mounted) return;
    _controller.showPassDialog(context, passCountry);
    setState(() {
      _animController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GameScaffold(
      title: Localization.t('game_coatofarms.title'),
      backgroundColors: _controller.getBackgroundColors(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arma Kartı
              ScaleTransition(
                scale: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFF7B1FA2).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B1FA2).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CoatOfArmsLoader.buildCoatOfArmsImage(
                      url: _controller.targetCoatOfArmsUrl,
                      height: 230,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Oyun alanı
              if (_controller.isButtonMode)
                GameButtonModeUI(onButtonPressed: _checkAnswer)
              else
                GameKeyboardModeUI(
                  controller: _controller.textController,
                  cardBg: _controller.cardBg,
                  textColor: _controller.textColor,
                  accentColor: _controller.accentColor,
                  prefixIcon: Icons.shield,
                  onCountrySelected: (Country selected) => _checkAnswer(4),
                ),

              // Pas butonu (Sadece klavye modunda)
              if (!_controller.isButtonMode) ...[
                const SizedBox(height: 20),
                GamePassButton(onPressed: _handlePass),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
