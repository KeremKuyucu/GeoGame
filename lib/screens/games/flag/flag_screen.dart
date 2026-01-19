import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/flag_loader.dart';
import 'package:geogame/widgets/game_widgets.dart';

import 'flag_controller.dart';

class FlagGame extends StatefulWidget {
  const FlagGame({super.key});

  @override
  State<FlagGame> createState() => _FlagGameState();
}

class _FlagGameState extends State<FlagGame>
    with SingleTickerProviderStateMixin {
  final FlagGameController _controller = FlagGameController();

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
      title: Localization.t('game_flag.title'),
      backgroundColors: _controller.getBackgroundColors(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bayrak kartı
              ScaleTransition(
                scale: _fadeAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FutureBuilder<bool>(
                      future: FlagLoader.checkFlagAsset(_controller.targetIso2),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 250,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final bool exists = snapshot.data ?? false;
                        return FlagLoader.buildFlagImage(
                          existsLocally: exists,
                          iso2: _controller.targetIso2,
                          url: _controller.targetFlagUrl,
                          height: 250,
                        );
                      },
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
                  prefixIcon: Icons.flag,
                  onCountrySelected: (Country selected) => _checkAnswer(4),
                ),

              const SizedBox(height: 20),

              // Pas butonu
              GamePassButton(onPressed: _handlePass),
            ],
          ),
        ),
      ),
    );
  }
}
