import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/flag_loader.dart';

/// Oyun AppBar widget'ı
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GameAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Oyun arka plan gradient'i
class GameBackground extends StatelessWidget {
  final List<Color> colors;
  final Widget child;

  const GameBackground({
    super.key,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

/// Çoktan seçmeli buton UI'ı
class GameButtonModeUI extends StatelessWidget {
  final Function(int) onButtonPressed;

  const GameButtonModeUI({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: GameOptionButton(index: 0, onPressed: onButtonPressed)),
            const SizedBox(width: 15),
            Expanded(
                child: GameOptionButton(index: 1, onPressed: onButtonPressed)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
                child: GameOptionButton(index: 2, onPressed: onButtonPressed)),
            const SizedBox(width: 15),
            Expanded(
                child: GameOptionButton(index: 3, onPressed: onButtonPressed)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          Localization.t('game_common.options_hint'),
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
          ),
        ),
      ],
    );
  }
}

/// Tek seçenek butonu
class GameOptionButton extends StatelessWidget {
  final int index;
  final Function(int) onPressed;
  final double height;

  const GameOptionButton({
    super.key,
    required this.index,
    required this.onPressed,
    this.height = 65,
  });

  @override
  Widget build(BuildContext context) {
    final button = AppState.buttons[index];

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: button.isActive ? () => onPressed(index) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: button.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: button.isActive ? 5 : 0,
          shadowColor: button.color.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        child: Text(
          button.label,
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

/// Klavye modu Autocomplete UI'ı
class GameKeyboardModeUI extends StatelessWidget {
  final TextEditingController controller;
  final Color cardBg;
  final Color textColor;
  final Color accentColor;
  final IconData prefixIcon;
  final Function(Country) onCountrySelected;
  final bool showFlagInOptions;

  const GameKeyboardModeUI({
    super.key,
    required this.controller,
    required this.cardBg,
    required this.textColor,
    required this.accentColor,
    required this.onCountrySelected,
    this.prefixIcon = Icons.search,
    this.showFlagInOptions = false,
  });

  @override
  Widget build(BuildContext context) {
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
            return AppState.allCountries.where((Country country) {
              final String name =
                  country.getLocalizedName(Localization.currentLanguage);
              return name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (Country selected) {
            controller.text =
                selected.getLocalizedName(Localization.currentLanguage);
            FocusScope.of(context).unfocus();
            onCountrySelected(selected);
          },
          fieldViewBuilder:
              (context, fieldController, focusNode, onFieldSubmitted) {
            if (controller.text.isEmpty && fieldController.text.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                fieldController.clear();
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
                controller: fieldController,
                focusNode: focusNode,
                style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
                cursorColor: accentColor,
                decoration: InputDecoration(
                  hintText: Localization.t('game_common.input_hint'),
                  hintStyle: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade400),
                  prefixIcon: Icon(prefixIcon, color: accentColor),
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
                color: cardBg,
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
                        final Country option = options.elementAt(index);
                        return ListTile(
                          leading: showFlagInOptions
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2,
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                      ),
                                    ],
                                  ),
                                  child: FlagWidget(
                                    iso2: option.iso2,
                                    flagUrl: option.flagUrl,
                                    size: 40,
                                  ),
                                )
                              : null,
                          title: Text(
                            option
                                .getLocalizedName(Localization.currentLanguage),
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
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

/// Pas butonu
class GamePassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? textColor;

  const GamePassButton({
    super.key,
    required this.onPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppState.settings.darkTheme;
    final Color color =
        textColor ?? (isDark ? Colors.white70 : Colors.grey.shade700);

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.skip_next, color: color),
      label: Text(
        Localization.t('common.pass'),
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

/// Oyun scaffold wrapper'ı
class GameScaffold extends StatelessWidget {
  final String title;
  final List<Color> backgroundColors;
  final Widget body;

  const GameScaffold({
    super.key,
    required this.title,
    required this.backgroundColors,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GameAppBar(title: title),
      drawer: const DrawerWidget(),
      body: GameBackground(
        colors: backgroundColors,
        child: SafeArea(child: body),
      ),
    );
  }
}
