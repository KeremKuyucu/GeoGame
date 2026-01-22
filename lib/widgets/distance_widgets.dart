import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game/guess_result.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/flag_loader.dart';
import 'package:geogame/screens/games/distance/distance_controller.dart';

/// Distance oyunu input dashboard'u
class DistanceInputDashboard extends StatelessWidget {
  final DistanceGameController controller;
  final VoidCallback onAnswerSubmit;
  final VoidCallback onClearGuesses;
  final VoidCallback onPass;

  const DistanceInputDashboard({
    super.key,
    required this.controller,
    required this.onAnswerSubmit,
    required this.onClearGuesses,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Autocomplete input
          Autocomplete<Country>(
            displayStringForOption: (Country option) =>
                option.getLocalizedName(Localization.currentLanguage),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Country>.empty();
              }
              return AppState.allCountries.where((Country country) {
                final String name =
                    country.getLocalizedName(Localization.currentLanguage);
                return name
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (Country selected) {
              controller.textController.text =
                  selected.getLocalizedName(Localization.currentLanguage);
              FocusScope.of(context).unfocus();
              onAnswerSubmit();
            },
            fieldViewBuilder:
                (context, fieldController, focusNode, onFieldSubmitted) {
              if (controller.textController.text.isEmpty &&
                  fieldController.text.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  fieldController.clear();
                });
              }
              return Container(
                decoration: BoxDecoration(
                  color:
                      controller.isDark ? Colors.black26 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: fieldController,
                  focusNode: focusNode,
                  style: TextStyle(
                    color: controller.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: controller.accentColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: Localization.t('game_common.input_hint'),
                    hintStyle: TextStyle(
                      color: controller.isDark
                          ? Colors.grey
                          : Colors.grey.shade600,
                    ),
                    prefixIcon:
                        Icon(Icons.search, color: controller.accentColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8.0,
                  color: controller.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 64,
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
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
                            option
                                .getLocalizedName(Localization.currentLanguage),
                            style: TextStyle(
                              color: controller.textColor,
                              fontWeight: FontWeight.w500,
                            ),
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

          const SizedBox(height: 16),

          // Aksiyon butonları
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearGuesses,
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: Text(Localization.t('game_common.clear_guesses')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPass,
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: Text(Localization.t('common.pass')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Boş durum widget'ı
class DistanceEmptyState extends StatelessWidget {
  final bool isDark;

  const DistanceEmptyState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 100,
            color: isDark ? Colors.white24 : Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            Localization.t('game_common.first_guess'),
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tahmin kartı
class DistanceGuessCard extends StatelessWidget {
  final GuessResultModel guess;
  final Color cardBg;
  final Color textColor;
  final bool isFirst;

  const DistanceGuessCard({
    super.key,
    required this.guess,
    required this.cardBg,
    required this.textColor,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    const double maxDist = 15000.0;
    final double ratio = (guess.distanceKm / maxDist).clamp(0.0, 1.0);
    final Color distanceColor = Color.lerp(
      Colors.greenAccent.shade700,
      Colors.redAccent,
      ratio,
    )!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: isFirst
            ? Border.all(color: distanceColor.withValues(alpha: 0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Sol: Ülke ismi ve mesafe
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guess.countryName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: distanceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.straighten, size: 14, color: distanceColor),
                        const SizedBox(width: 6),
                        Text(
                          "${guess.distanceKm.toInt()} km",
                          style: TextStyle(
                            color: distanceColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sağ: Yön oku
            Column(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppState.settings.darkTheme
                        ? Colors.black26
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    angle: guess.bearing * (math.pi / 180),
                    child: Icon(
                      Icons.navigation,
                      size: 24,
                      color: distanceColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guess.directionText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
