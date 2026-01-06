import 'package:flutter/material.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';
import 'dart:async';

import 'package:geogame/models/app_context.dart';

import 'package:geogame/services/preferences_service.dart';
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
      setState(() {
        // Profil verilerini güncelleyen servis çağrısı buraya gelebilir
      });
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

  void restartApp(BuildContext context) async {
    AppState.selectedIndex = 0;
    await Localization.init(userPref: AppState.settings.language);
    if (context.mounted) {
      RestartWidget.restartApp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // iOS Settings tarzı arka plan renkleri
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
        backgroundColor: Colors.transparent, // Saydam AppBar
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

  // --- BÖLÜM 1: HESAP KARTI (YENİ TASARIM) ---

  Widget _buildAccountSection(bool isDark) {
    // Kartın arka planı
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
              onBackgroundImageError: (_, __) {}, // Hata durumunda varsayılanı gösterir
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
        icon: Icons.grid_view_rounded, // Daha modern ikon
        iconColor: Colors.deepPurple,
        isSwitch: true,
        switchValue: AppState.filter.isButtonMode,
        onSwitchChanged: (v) => setState(() {
          AppState.filter.isButtonMode = v;
          PreferencesService.saveConfig();
        }),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.selected_theme', args: [AppState.settings.darkTheme ? 'Dark' : 'Light']),
        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        iconColor: isDark ? Colors.amber : Colors.orange,
        isSwitch: true,
        switchValue: AppState.settings.darkTheme,
        onSwitchChanged: (v) {
          setState(() {
            AppState.settings.darkTheme = v;
            v ? ThemeModeBuilderConfig.setDark() : ThemeModeBuilderConfig.setLight();
            PreferencesService.saveConfig();
          });
        },
      ),
      _buildDivider(isDark),
      _buildLanguageTile(isDark),
    ]);
  }

  Widget _buildLanguageTile(bool isDark) {
    final String currentValue = AppState.settings.language;

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
        // KRİTİK DÜZELTME: Maksimum genişlik sınırı koyuyoruz.
        // Böylece Dropdown sonsuza kadar uzamaya çalışıp hata vermiyor.
        constraints: const BoxConstraints(maxWidth: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true, // Konteynırın içine tam sığması için
              value: Localization.supportedLanguages.contains(currentValue)
                  ? currentValue
                  : 'eng',
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500
              ),
              // Metin taşarsa "..." koysun diye Text'e overflow ekledik
              items: Localization.supportedLanguages.map((String code) => DropdownMenuItem(
                value: code,
                child: Text(
                  Localization.getDisplayName(code),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null && newValue != AppState.settings.language) {
                  AppState.settings.language = newValue;
                  await PreferencesService.saveConfig();
                  await Localization.changeLanguage(newValue);
                  if (mounted) {
                    restartApp(context);
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
        icon: Icons.euro_rounded, // Sembolik
        iconColor: Colors.blueAccent,
        isSwitch: true,
        switchValue: AppState.filter.europe,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.europe = v),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.asia'),
        icon: Icons.temple_buddhist,
        iconColor: Colors.redAccent,
        isSwitch: true,
        switchValue: AppState.filter.asia,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.asia = v),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.africa'),
        icon: Icons.landscape_rounded,
        iconColor: Colors.orange,
        isSwitch: true,
        switchValue: AppState.filter.africa,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.africa = v),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.north_america'),
        icon: Icons.location_city_rounded,
        iconColor: Colors.green,
        isSwitch: true,
        switchValue: AppState.filter.northAmerica,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.northAmerica = v),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.south_america'),
        icon: Icons.forest_rounded,
        iconColor: Colors.teal,
        isSwitch: true,
        switchValue: AppState.filter.southAmerica,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.southAmerica = v),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.oceania'),
        icon: Icons.surfing_rounded,
        iconColor: Colors.cyan,
        isSwitch: true,
        switchValue: AppState.filter.oceania,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.oceania = v),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.continents.antarctica'),
        icon: Icons.ac_unit_rounded,
        iconColor: Colors.lightBlueAccent,
        isSwitch: true,
        switchValue: AppState.filter.antarctic,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.antarctic = v),
      ),
      _buildDivider(isDark),
      _buildSettingsTile(
        title: Localization.t('settings.un_members'),
        icon: Icons.flag_circle_rounded,
        iconColor: Colors.indigoAccent,
        isSwitch: true,
        switchValue: AppState.filter.includeNonUN,
        onSwitchChanged: (v) => _updateContinent(() => AppState.filter.includeNonUN = v),
      ),
    ]);
  }

  void _updateContinent(VoidCallback action) {
    setState(() {
      action();
      AppState.activePool = AppState.filteredCountries;
      PreferencesService.saveConfig();
    });
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

  // Tekil bir ayar satırı (Modern Stil)
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

  // iOS tarzı yuvarlak köşeli ikon kutusu
  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8), // Squircle
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56, // İkon hizasından sonra başlar
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
            "v${AppState.version}",
            style: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

}