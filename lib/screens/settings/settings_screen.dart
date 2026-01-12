import 'package:flutter/material.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/settings_widgets.dart';

import 'settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _controller = SettingsController();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          Localization.t('settings.title').toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.orange,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const DrawerWidget(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // Hesap bölümü
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
                      final successMessage = Localization.t('auth.logout_success');
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
              onEditComplete: () => setState(() {}),
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
              SettingsTile(
                title: Localization.t('settings.selected_theme',
                    args: [_controller.isDarkTheme ? 'Dark' : 'Light']),
                icon:
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: isDark ? Colors.amber : Colors.orange,
                isDark: isDark,
                isSwitch: true,
                switchValue: _controller.isDarkTheme,
                onSwitchChanged: (v) =>
                    setState(() => _controller.setDarkTheme(v)),
              ),
              SettingsDivider(isDark: isDark),
              SettingsLanguageTile(
                controller: _controller,
                isDark: isDark,
                onLanguageChanged: () => setState(() {}),
              ),
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
          const SizedBox(height: 40),

          // Versiyon bilgisi
          SettingsVersionInfo(isDark: isDark, version: _controller.appVersion),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
