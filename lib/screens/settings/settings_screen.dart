import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/ad_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/feedback_dialog.dart';
import 'package:geogame/widgets/settings_widgets.dart';

import 'package:geogame/screens/settings/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _controller = SettingsController();
  String _appVersion = '';
  bool _isPrivacyOptionsRequired = false;

  @override
  void initState() {
    super.initState();
    AppState.userNotifier.addListener(_onUserChanged);
    _loadAppVersion();
    _checkPrivacyOptions();
  }

  Future<void> _checkPrivacyOptions() async {
    final bool required = await AdService.isPrivacyOptionsRequired();
    if (mounted && required != _isPrivacyOptionsRequired) {
      setState(() {
        _isPrivacyOptionsRequired = required;
      });
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'GeoGame v${info.version}';
        });
      }
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
  }

  @override
  void dispose() {
    AppState.userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              Localization.t('settings.title').toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white : const Color(0xFF2C2C3E),
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _controller.getBackgroundColors(isDark),
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16.0,
            kToolbarHeight + MediaQuery.of(context).padding.top + 8,
            16.0,
            95.0,
          ),
          children: [
            // Hesap bölümü
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E2C).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            child: !_controller.isAuthenticated
                ? SettingsGuestCard(
                    controller: _controller,
                    isDark: isDark,
                    onAuthComplete: () => setState(() {}),
                  )
                : SettingsProfileCard(
                    controller: _controller,
                    isDark: isDark,
                    onSignOut: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final successMessage =
                          Localization.t('auth.logout_success');
                      await _controller.signOut();
                      if (!mounted) return;
                      setState(() {});
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(successMessage),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 25),

          // Genel ayarlar
          SettingsSectionHeader(
              title: Localization.t('settings.general_title')),
          SettingsContainer(
            isDark: isDark,
            children: [
              SettingsTile(
                title: Localization.t('settings.multiple_choice_mode'),
                icon: Icons.grid_view_rounded,
                iconColor: Colors.deepPurple,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.isButtonMode,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setButtonMode(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsThemeTile(
                controller: _controller,
                isDark: isDark,
                onThemeChanged: () => setState(() {}),
              ),
              SettingsDivider(isDark: isDark),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.security_rounded,
                      color: Colors.white, size: 20),
                ),
                title: Text(
                  Localization.t('settings.use_anonymous_data'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () async {
                  if (_controller.isTelemetryEnabled) {
                    final shouldDisable =
                        await _showTelemetryConfirmDialog(context, isDark);
                    if (shouldDisable == true) {
                      setState(() => _controller.setTelemetryEnabled(false));
                    }
                  } else {
                    setState(() => _controller.setTelemetryEnabled(true));
                  }
                },
                trailing: Switch.adaptive(
                  value: _controller.isTelemetryEnabled,
                  onChanged: (v) async {
                    if (!v) {
                      final shouldDisable =
                          await _showTelemetryConfirmDialog(context, isDark);
                      if (shouldDisable != true) return;
                    }

                    setState(() => _controller.setTelemetryEnabled(v));
                  },
                  activeThumbColor: Colors.green,
                ),
              ),
              SettingsDivider(isDark: isDark),
              SettingsLanguageTile(
                controller: _controller,
                isDark: isDark,
                onLanguageChanged: () => setState(() {}),
              ),
              if (AdService.isSupported && _isPrivacyOptionsRequired) ...[
                SettingsDivider(isDark: isDark),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.ads_click_rounded,
                        color: Colors.white, size: 20),
                  ),
                  title: Text(
                    Localization.t('settings.ad_preferences'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    Localization.t('settings.ad_preferences_desc'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onTap: () {
                    AdService.showPrivacyOptionsForm(context);
                  },
                ),
              ],
              SettingsDivider(isDark: isDark),
            ],
          ),
          const SizedBox(height: 25),

          // Kıta filtreleri
          SettingsSectionHeader(
              title: Localization.t('settings.continent_title')),
          SettingsContainer(
            isDark: isDark,
            children: [
              SettingsTile(
                title: Localization.t('settings.continents.europe'),
                icon: Icons.euro_rounded,
                iconColor: Colors.blueAccent,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.europeEnabled,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setEuropeFilter(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.continents.asia'),
                icon: Icons.temple_buddhist,
                iconColor: Colors.redAccent,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.asiaEnabled,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setAsiaFilter(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.continents.africa'),
                icon: Icons.landscape_rounded,
                iconColor: Colors.orange,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.africaEnabled,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setAfricaFilter(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.continents.north_america'),
                icon: Icons.location_city_rounded,
                iconColor: Colors.green,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.northAmericaEnabled,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setNorthAmericaFilter(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.continents.south_america'),
                icon: Icons.forest_rounded,
                iconColor: Colors.teal,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.southAmericaEnabled,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setSouthAmericaFilter(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.continents.oceania'),
                icon: Icons.surfing_rounded,
                iconColor: Colors.cyan,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.oceaniaEnabled,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setOceaniaFilter(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.continents.antarctica'),
                icon: Icons.ac_unit_rounded,
                iconColor: Colors.lightBlueAccent,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.antarcticaEnabled,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setAntarcticaFilter(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.un_members'),
                icon: Icons.flag_circle_rounded,
                iconColor: Colors.indigoAccent,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.includeNonUN,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setIncludeNonUN(v)),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Destek ve Hakkında Bölümü
          SettingsSectionHeader(
            title: Localization.t('settings.support_title'),
          ),
          SettingsContainer(
            isDark: isDark,
            children: [
              SettingsTile(
                title: Localization.t('settings.rate_play_store'),
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber.shade700,
                isDark: isDark,
                onTap: _launchPlayStore,
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.report_bug'),
                icon: Icons.bug_report_rounded,
                iconColor: Colors.deepOrangeAccent,
                isDark: isDark,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const FeedbackDialog(),
                  );
                },
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.geogame_website'),
                icon: Icons.public_rounded,
                iconColor: Colors.redAccent,
                isDark: isDark,
                onTap: () => _launchURL('https://geogame.keremkuyucu.com.tr'),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                title: Localization.t('settings.geogame_github'),
                icon: Icons.code_rounded,
                iconColor: isDark ? Colors.white70 : Colors.black87,
                isDark: isDark,
                onTap: () => _launchURL('https://github.com/KeremKuyucu/GeoGame'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  _appVersion.isNotEmpty ? _appVersion : 'GeoGame',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Localization.t('settings.creator'),
                  style: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}

  Future<void> _launchPlayStore() async {
    final Uri marketUri =
        Uri.parse('market://details?id=com.keremkuyucu.geogame');
    final Uri webUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.keremkuyucu.geogame');

    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Play Store linki açılamadı: $e');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Link açılamadı: $urlString');
    }
  }

  Future<bool?> _showTelemetryConfirmDialog(BuildContext context, bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          Localization.t('settings.telemetry_dialog_title'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          Localization.t('settings.telemetry_dialog_message'),
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              Localization.t('settings.telemetry_cancel'),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(Localization.t('settings.telemetry_disable')),
          ),
        ],
      ),
    );
  }
}
