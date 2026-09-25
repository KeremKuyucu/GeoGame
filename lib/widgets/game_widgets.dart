import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';
import 'package:geogame/services/ad_service.dart';
import 'package:geogame/services/bonus_service.dart';
import 'package:geogame/services/game_service.dart';
import 'package:geogame/screens/settings/settings_controller.dart';
import 'package:geogame/widgets/flag_loader.dart';
import 'package:geogame/widgets/ad_banner_widget.dart';

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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => GameScaffold.handleGameExit(context),
      ),
      actions: [
        if (!kIsWeb)
          ValueListenableBuilder<bool>(
            valueListenable: AppState.childModeNotifier,
            builder: (context, isChild, _) {
              if (isChild) return const SizedBox.shrink();
              return const _BonusButton();
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 2x Puan Bonusu butonu (Ödüllü reklam izletir, 5 dk 2x verir, stacklenebilir)
class _BonusButton extends StatefulWidget {
  const _BonusButton();

  @override
  State<_BonusButton> createState() => _BonusButtonState();
}

class _BonusButtonState extends State<_BonusButton> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    BonusService.bonusEndTimeNotifier.addListener(_onBonusChanged);
    _checkTimer();
  }

  @override
  void dispose() {
    BonusService.bonusEndTimeNotifier.removeListener(_onBonusChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _onBonusChanged() {
    _checkTimer();
    if (mounted) setState(() {});
  }

  void _checkTimer() {
    if (BonusService.isActive) {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!BonusService.isActive) {
          timer.cancel();
          _timer = null;
        }
        if (mounted) setState(() {});
      });
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _handleTap() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final shown = await AdService.showRewardedAd(
      onRewarded: () {
        BonusService.activate();
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text(
                '🎉 2x Puan Bonusu Aktif! (+5 dakika eklendi)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.amber.shade800,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
    );

    if (!shown && mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Reklam hazırlanıyor, lütfen birazdan tekrar deneyin.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = BonusService.isActive;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Tooltip(
          message: isActive
              ? '2x Puan Bonusu Aktif! Süreyi uzatmak için dokun (+5 dk)'
              : 'Ödüllü reklam izle, 5 dakika 2x puan kazan!',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _handleTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [Color(0xFFFF8F00), Color(0xFFFF3D00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.orange.shade800,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? Colors.amberAccent
                        : Colors.amber.shade200.withValues(alpha: 0.6),
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? Colors.deepOrange : Colors.amber)
                          .withValues(alpha: 0.45),
                      blurRadius: isActive ? 8 : 4,
                      spreadRadius: isActive ? 1 : 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.bolt_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive
                          ? '2x ${BonusService.formattedRemainingTime}'
                          : '2x BONUS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    final bool isDark = SettingsController.settings.darkTheme;

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
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 12,
            shadows: isDark
                ? const [Shadow(blurRadius: 2, color: Colors.black45)]
                : null,
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
    final button = GameService.buttonAt(index);

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
    final bool isDark = SettingsController.settings.darkTheme;

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
    final bool isDark = SettingsController.settings.darkTheme;
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

  /// Oyunlardan çıkış mantığı (Hem AppBar Geri/Home tuşları hem de cihazın Geri tuşu için ortak)
  static void handleGameExit(BuildContext context) {
    AdService.showInterstitialAd();
    GameLogService.syncPendingLogs();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        handleGameExit(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GameAppBar(title: title),
        body: GameBackground(
          colors: backgroundColors,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(child: body),
                const AdBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
