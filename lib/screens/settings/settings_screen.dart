// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';

import 'package:geogame/services/settings_service.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';

import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/restart_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  // --- ACTIONS ---

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (mounted) {
      setState(() {});
      _showSnackBar(Localization.t('auth.logout_success'), Colors.green);
    }
  }

  Future<void> _openEditProfile() async {
    await Navigator.pushNamed(context, '/profile/edit');

    if (mounted) {
      setState(() {});
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _restartApp(BuildContext context) async {
    AppState.selectedIndex = 0;
    await Localization.init(userPref: SettingsService.currentLanguage);
    if (context.mounted) {
      RestartWidget.restartApp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          Localization.t('settings.title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
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
              child: Icon(Icons.menu_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
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
          _buildAccountSection(isDark),
          const SizedBox(height: 25),

          _buildSectionHeader(Localization.t('settings.general_title')),
          _buildGeneralSettings(isDark),

          const SizedBox(height: 25),

          _buildSectionHeader(Localization.t('settings.continent_title')),
          _buildContinentSettings(isDark),

          const SizedBox(height: 40),
          _buildVersionInfo(isDark),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- BÖLÜM 1: HESAP KARTI ---

  Widget _buildAccountSection(bool isDark) {
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: !AuthService.isAuthenticated ? _buildGuestUI(isDark) : _buildProfileUI(isDark),
    );
  }

  Widget _buildGuestUI(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded, size: 48, color: Colors.blueAccent),
          ),
          const SizedBox(height: 16),
          Text(
            Localization.t('settings.guest'),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Localization.t('auth.login_description'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/auth');
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("${Localization.t('auth.login')} / ${Localization.t('auth.signup')}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileUI(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(AppState.user.avatarUrl),
              onBackgroundImageError: (_, __) {},
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(width: 20),

          // İsim ve Düzenle Linki
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppState.user.name,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _openEditProfile,
                  child: Row(
                    children: [
                      Text(
                        Localization.t('settings.edit_profile'),
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.blueAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Çıkış Butonu
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: Localization.t('auth.logout'),
            ),
          ),
        ],
      ),
    );
  }

  // --- BÖLÜM 2: GENEL AYARLAR ---

  Widget _buildGeneralSettings(bool isDark) {
    return _buildSettingsContainer(isDark, [
      _buildSettingsTile(
        title: Localization.t('settings.multiple_choice_mode'),
        icon: Icons.grid_view_rounded,
        iconColor: Colors.deepPurple,
        isSwitch: true,
        switchValue: SettingsService.isButtonMode,
        onSwitchChanged: (v) => setState(() {
          SettingsService.setButtonMode(v);
        }),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.selected_theme', args: [SettingsService.isDarkTheme ? 'Dark' : 'Light']),
        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        iconColor: isDark ? Colors.amber : Colors.orange,
        isSwitch: true,
        switchValue: SettingsService.isDarkTheme,
        onSwitchChanged: (v) {
          setState(() {
            SettingsService.setDarkTheme(v);
          });
        },
      ),
      _buildDivider(isDark),
      _buildLanguageTile(isDark),
    ]);
  }

  Widget _buildLanguageTile(bool isDark) {
    final String currentValue = SettingsService.currentLanguage;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIconContainer(Icons.language_rounded, Colors.blue),
      title: Text(
        Localization.t('settings.lang'),
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87
        ),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: Localization.supportedLanguages.contains(currentValue)
                  ? currentValue
                  : 'eng',
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500
              ),
              items: Localization.supportedLanguages.map((String code) => DropdownMenuItem(
                value: code,
                child: Text(
                  Localization.getDisplayName(code),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null && newValue != SettingsService.currentLanguage) {
                  await SettingsService.changeLanguage(newValue);
                  if (mounted) {
                    _restartApp(context);
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- BÖLÜM 3: KITALAR ---

  Widget _buildContinentSettings(bool isDark) {
    return _buildSettingsContainer(isDark, [
      _buildSettingsTile(
        title: Localization.t('settings.continents.europe'),
        icon: Icons.euro_rounded,
        iconColor: Colors.blueAccent,
        isSwitch: true,
        switchValue: SettingsService.europeEnabled,
        onSwitchChanged: (v) => setState(() => SettingsService.setEuropeFilter(v)),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.asia'),
        icon: Icons.temple_buddhist,
        iconColor: Colors.redAccent,
        isSwitch: true,
        switchValue: SettingsService.asiaEnabled,
        onSwitchChanged: (v) => setState(() => SettingsService.setAsiaFilter(v)),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.africa'),
        icon: Icons.landscape_rounded,
        iconColor: Colors.orange,
        isSwitch: true,
        switchValue: SettingsService.africaEnabled,
        onSwitchChanged: (v) => setState(() => SettingsService.setAfricaFilter(v)),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.north_america'),
        icon: Icons.location_city_rounded,
        iconColor: Colors.green,
        isSwitch: true,
        switchValue: SettingsService.northAmericaEnabled,
        onSwitchChanged: (v) => setState(() => SettingsService.setNorthAmericaFilter(v)),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.south_america'),
        icon: Icons.forest_rounded,
        iconColor: Colors.teal,
        isSwitch: true,
        switchValue: SettingsService.southAmericaEnabled,
        onSwitchChanged: (v) => setState(() => SettingsService.setSouthAmericaFilter(v)),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.oceania'),
        icon: Icons.surfing_rounded,
        iconColor: Colors.cyan,
        isSwitch: true,
        switchValue: SettingsService.oceaniaEnabled,
        onSwitchChanged: (v) => setState(() => SettingsService.setOceaniaFilter(v)),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.antarctica'),
        icon: Icons.ac_unit_rounded,
        iconColor: Colors.lightBlueAccent,
        isSwitch: true,
        switchValue: SettingsService.antarcticaEnabled,
        onSwitchChanged: (v) => setState(() => SettingsService.setAntarcticaFilter(v)),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.un_members'),
        icon: Icons.flag_circle_rounded,
        iconColor: Colors.indigoAccent,
        isSwitch: true,
        switchValue: SettingsService.includeNonUN,
        onSwitchChanged: (v) => setState(() => SettingsService.setIncludeNonUN(v)),
      ),
    ]);
  }

  // --- YARDIMCI WIDGETLAR ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIconContainer(icon, iconColor),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87
        ),
      ),
      trailing: isSwitch
          ? Switch.adaptive(
        value: switchValue,
        onChanged: onSwitchChanged,
        activeThumbColor: Colors.green,
      )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildVersionInfo(bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            "GeoGame",
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          ),
          Text(
            "v${SettingsService.appVersion}",
            style: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
