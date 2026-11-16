import 'package:flutter/material.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/ad_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/settings_widgets.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _controller = SettingsController();

  @override
  void initState() {
    super.initState();
    AuthService.userNotifier.addListener(_onUserChanged);
    _initSettingsData();
  }

  Future<void> _initSettingsData() async {
    await Future.wait([
      _controller.loadAppVersion(),
      _controller.checkPrivacyOptionsRequired(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AuthService.userNotifier.removeListener(_onUserChanged);
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
                        await _controller.handleSignOut(context);
                        if (mounted) setState(() {});
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
                    await _controller.handleTelemetryChange(
                      context,
                      !_controller.isTelemetryEnabled,
                      isDark,
                    );
                    if (mounted) setState(() {});
                  },
                  trailing: Switch.adaptive(
                    value: _controller.isTelemetryEnabled,
                    onChanged: (v) async {
                      await _controller.handleTelemetryChange(
                          context, v, isDark);
                      if (mounted) setState(() {});
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
                if (AdService.isSupported &&
                    _controller.isPrivacyOptionsRequired) ...[
                  SettingsDivider(isDark: isDark),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
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
                    onTap: () => _controller.showAdPreferences(context),
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
                  onTap: _controller.launchPlayStore,
                ),
                SettingsDivider(isDark: isDark),
                SettingsTile(
                  title: Localization.t('settings.report_bug'),
                  icon: Icons.bug_report_rounded,
                  iconColor: Colors.deepOrangeAccent,
                  isDark: isDark,
                  onTap: () => _controller.showFeedbackDialog(context),
                ),
                SettingsDivider(isDark: isDark),
                SettingsTile(
                  title: Localization.t('settings.geogame_website'),
                  icon: Icons.public_rounded,
                  iconColor: Colors.redAccent,
                  isDark: isDark,
                  onTap: _controller.openWebsite,
                ),
                SettingsDivider(isDark: isDark),
                SettingsTile(
                  title: Localization.t('settings.geogame_github'),
                  icon: Icons.code_rounded,
                  iconColor: isDark ? Colors.white70 : Colors.black87,
                  isDark: isDark,
                  onTap: _controller.openGitHub,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    _controller.appVersion.isNotEmpty
                        ? _controller.appVersion
                        : 'GeoGame',
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
}
