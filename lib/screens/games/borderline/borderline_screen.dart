import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/borderline_widgets.dart';
import 'package:geogame/widgets/game_widgets.dart';

import 'borderline_controller.dart';

class BorderLineGame extends StatefulWidget {
  const BorderLineGame({super.key});

  @override
  State<BorderLineGame> createState() => _BorderLineGameState();
}

class _BorderLineGameState extends State<BorderLineGame>
    with SingleTickerProviderStateMixin {
  final BorderLineGameController _controller = BorderLineGameController();

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.elasticOut);

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
    setState(() {});
    _animController.forward(from: 0.0);
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
      title: Localization.t('game_borderline.title'),
      backgroundColors: _controller.getBackgroundColors(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Harita/şekil alanı
              ScaleTransition(
                scale: _scaleAnimation,
                child: BorderLineMapContainer(
                  controller: _controller,
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
                  prefixIcon: Icons.map,
                  showFlagInOptions: true,
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
