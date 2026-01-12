import 'package:flutter/material.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/flag_loader.dart';
import 'package:geogame/screens/games/borderpath/borderpath_controller.dart';

/// Başlangıç/Bitiş kartı
class BorderPathStartEndCard extends StatelessWidget {
  final BorderPathGameController controller;

  const BorderPathStartEndCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: controller.cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CountryInfo(
                  label: Localization.t('game_borderpath.label_start'),
                  country: controller.startCountry!,
                  color: Colors.green,
                  textColor: controller.textColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_forward,
                  color: controller.textColor.withValues(alpha: 0.5),
                  size: 30,
                ),
              ),
              Expanded(
                child: _CountryInfo(
                  label: Localization.t('game_borderpath.label_target'),
                  country: controller.targetCountry!,
                  color: Colors.red,
                  textColor: controller.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(
                  label: Localization.t('game_borderpath.label_moves'),
                  value: "${controller.movesCount}",
                  icon: Icons.numbers,
                ),
                _InfoChip(
                  label: Localization.t('game_borderpath.label_optimal'),
                  value: "${controller.optimalPathLength}",
                  icon: Icons.route,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryInfo extends StatelessWidget {
  final String label;
  final Country country;
  final Color color;
  final Color textColor;

  const _CountryInfo({
    required this.label,
    required this.country,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          country.getLocalizedName(Localization.currentLanguage),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 5),
        Text("$label: ", style: const TextStyle(fontSize: 14)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// Harita alanı
class BorderPathMapArea extends StatelessWidget {
  final BorderPathGameController controller;

  const BorderPathMapArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: controller.isDark ? Colors.black26 : Colors.white54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: controller.isDark
              ? Colors.white10
              : Colors.indigo.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: controller.isLoadingMaps
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: controller.isDark ? Colors.white : Colors.indigo,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Localization.t('game_borderpath.loading_map'),
                      style: TextStyle(
                          color: controller.textColor.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              )
            : InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 5.0,
                child: RepaintBoundary(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: false,
                    painter: PathMapPainter(
                      paths: controller.countryPaths,
                      currentPath: controller.currentPath,
                      targetCountry: controller.targetCountry!,
                      isDark: controller.isDark,
                    ),
                    child: Container(),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Mevcut yol kartı
class BorderPathCurrentPath extends StatelessWidget {
  final BorderPathGameController controller;

  const BorderPathCurrentPath({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: controller.cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: Colors.indigo),
              const SizedBox(width: 10),
              Text(
                Localization.t('game_borderpath.current_path'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: controller.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.currentPath.asMap().entries.map((entry) {
              int index = entry.key;
              Country country = entry.value;
              bool isStart = index == 0;
              bool isEnd = country.iso3 == controller.targetCountry!.iso3;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isEnd
                      ? Colors.red.withValues(alpha: 0.2)
                      : isStart
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isEnd
                        ? Colors.red
                        : isStart
                            ? Colors.green
                            : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${index + 1}.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.textColor),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      country.getLocalizedName(Localization.currentLanguage),
                      style: TextStyle(color: controller.textColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Komşular bölümü
class BorderPathNeighborsSection extends StatelessWidget {
  final BorderPathGameController controller;
  final Function(Country) onCountrySelected;

  const BorderPathNeighborsSection({
    super.key,
    required this.controller,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.isButtonMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              Localization.t('game_borderpath.neighbors_label'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.textColor,
              ),
            ),
          ),
          _buildKeyboardModeUI(context),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: controller.cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Colors.indigo),
              const SizedBox(width: 10),
              Text(
                "${Localization.t('game_borderpath.neighbors_label')} (${controller.availableNeighbors.length})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: controller.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (controller.availableNeighbors.isEmpty)
            Center(
              child: Text(
                Localization.t('game_borderpath.no_neighbors_left'),
                style: const TextStyle(
                    color: Colors.red, fontStyle: FontStyle.italic),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.availableNeighbors.map((country) {
                bool isTarget = country.iso3 == controller.targetCountry!.iso3;
                return ElevatedButton(
                  onPressed: () => onCountrySelected(country),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTarget ? Colors.red : Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTarget)
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(Icons.flag, size: 16),
                        ),
                      Text(
                        country.getLocalizedName(Localization.currentLanguage),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyboardModeUI(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<Country>(
          displayStringForOption: (Country option) =>
              option.getLocalizedName(Localization.currentLanguage),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Country>.empty();
            }
            return controller.availableNeighbors.where((Country country) {
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
            onCountrySelected(selected);
          },
          fieldViewBuilder:
              (context, fieldController, focusNode, onFieldSubmitted) {
            if (controller.textController.text.isEmpty &&
                fieldController.text.isNotEmpty) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => fieldController.clear());
            }
            return Container(
              decoration: BoxDecoration(
                color: controller.cardBg,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: fieldController,
                focusNode: focusNode,
                style: TextStyle(
                    color: controller.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
                cursorColor: Colors.indigo,
                decoration: InputDecoration(
                  hintText: Localization.t('game_common.input_hint'),
                  hintStyle: TextStyle(
                      color: controller.isDark
                          ? Colors.grey
                          : Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: constraints.maxWidth,
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
                      bool isTarget =
                          option.iso3 == controller.targetCountry!.iso3;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.black.withValues(alpha: 0.1))
                            ],
                          ),
                          child: FlagWidget(
                              iso2: option.iso2,
                              flagUrl: option.flagUrl,
                              size: 40),
                        ),
                        title: Text(
                          option.getLocalizedName(Localization.currentLanguage),
                          style: TextStyle(
                            color: isTarget ? Colors.red : controller.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: isTarget
                            ? const Icon(Icons.flag,
                                color: Colors.red, size: 20)
                            : null,
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Harita çizen painter
class PathMapPainter extends CustomPainter {
  final Map<String, Path> paths;
  final List<Country> currentPath;
  final Country targetCountry;
  final bool isDark;

  PathMapPainter({
    required this.paths,
    required this.currentPath,
    required this.targetCountry,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    Rect? combinedBounds;
    for (final path in paths.values) {
      final bounds = path.getBounds();
      if (bounds.isEmpty) continue;
      combinedBounds = combinedBounds == null
          ? bounds
          : combinedBounds.expandToInclude(bounds);
    }

    if (combinedBounds == null || combinedBounds.isEmpty) return;

    final double scaleX = size.width / combinedBounds.width;
    final double scaleY = size.height / combinedBounds.height;
    final double scale = (scaleX < scaleY ? scaleX : scaleY) * 0.9;

    final double offsetX = (size.width - (combinedBounds.width * scale)) / 2;
    final double offsetY = (size.height - (combinedBounds.height * scale)) / 2;

    final Matrix4 matrix = Matrix4.identity();
    matrix.translateByDouble(offsetX, offsetY, 0.0, 1.0);
    matrix.scaleByDouble(scale, scale, 1.0, 1.0);
    matrix.translateByDouble(
        -combinedBounds.left, -combinedBounds.top, 0.0, 1.0);

    for (final entry in paths.entries) {
      final iso3 = entry.key;
      final path = entry.value;
      final transformedPath = path.transform(matrix.storage);

      Color fillColor;
      Color strokeColor;

      if (currentPath.isNotEmpty && iso3 == currentPath.first.iso3) {
        fillColor = Colors.green.withValues(alpha: 0.6);
        strokeColor = Colors.green.shade800;
      } else if (iso3 == targetCountry.iso3) {
        fillColor = Colors.red.withValues(alpha: 0.6);
        strokeColor = Colors.red.shade800;
      } else if (currentPath.any((c) => c.iso3 == iso3)) {
        fillColor = Colors.blue.withValues(alpha: 0.5);
        strokeColor = Colors.blue.shade800;
      } else {
        fillColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        strokeColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;
      }

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(transformedPath, fillPaint);
      canvas.drawPath(transformedPath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PathMapPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.currentPath != currentPath ||
        oldDelegate.targetCountry != targetCountry;
  }
}
