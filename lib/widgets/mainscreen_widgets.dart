import 'package:flutter/material.dart';

import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/widgets/game_card.dart';
import 'package:geogame/screens/mainscreen/main_screen_controller.dart';

/// Grid görünümü widget'ı
class MainScreenGameGrid extends StatelessWidget {
  final MainScreenController controller;

  const MainScreenGameGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
      ),
      itemCount: gameMetadataList.length,
      itemBuilder: (context, index) => GameCard(
        metadata: gameMetadataList[index],
        isGrid: true,
        onTap: () => controller.startGame(gameMetadataList[index]),
      ),
    );
  }
}

/// Liste görünümü widget'ı
class MainScreenGameList extends StatelessWidget {
  final MainScreenController controller;

  const MainScreenGameList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      itemCount: gameMetadataList.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: SizedBox(
          height: 200,
          child: GameCard(
            metadata: gameMetadataList[index],
            isGrid: false,
            onTap: () => controller.startGame(gameMetadataList[index]),
          ),
        ),
      ),
    );
  }
}
