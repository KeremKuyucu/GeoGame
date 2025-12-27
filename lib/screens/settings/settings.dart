import 'package:flutter/material.dart';
import 'package:geogame/screens/auth/authpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';
import 'dart:async';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/models/countries.dart';

import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';

import 'package:geogame/widgets/restart_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    _checkContinents();
  }

  Future<void> _checkContinents() async {
    if (getFilteredCountries().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showContinentWarning();
      });
    }
  }

  // --- ACTIONS ---

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (mounted) {
      setState(() {});
      _showSnackBar(Localization.t('auth.logout_success'), Colors.green);
    }
  }

  Future<void> _openWebAuth() async {
    final Uri url = Uri.parse('https://auth.keremkk.com.tr');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar(Localization.t('site_error', args: ["auth.keremkk.com.tr"]), Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7), // iOS tarzı gri arka plan
      appBar: AppBar(
        title: Text(
          Localization.t('settings.title').toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? Colors.orangeAccent : Colors.deepOrange,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const DrawerWidget(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        children: [
          _buildAccountSection(isDark),
          const SizedBox(height: 20),
          _buildSectionHeader(Localization.t('settings.general_title')), // "Genel Ayarlar"
          _buildGeneralSettings(isDark),
          const SizedBox(height: 20),
          _buildSectionHeader(Localization.t('settings.continent_title')), // "Kıtalar"
          _buildContinentSettings(isDark),
          const SizedBox(height: 40),
          _buildVersionInfo(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- BÖLÜM 1: HESAP KARTI ---

  Widget _buildAccountSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade900, Colors.black87]
              : [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: !AuthService.isAuthenticated ? _buildGuestUI(isDark) : _buildProfileUI(isDark),
    );
  }

  Widget _buildGuestUI(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(Icons.account_circle_outlined, size: 60, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            Localization.t('settings.guest'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            Localization.t('auth.login_description'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage(onLoginSuccess: () => setState(() {}))),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(Localization.t('auth.login')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _openWebAuth,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(Localization.t('auth.signup')),
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(AppState.user.avatarUrl),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppState.user.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: _openWebAuth,
                  child: Text(
                    Localization.t('settings.edit_profile'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: Localization.t('auth.logout'),
          ),
        ],
      ),
    );
  }

  // --- BÖLÜM 2: GENEL AYARLAR ---

  Widget _buildGeneralSettings(bool isDark) {
    return _buildSettingsContainer(isDark, [
      _buildSwitchTile(
        title: Localization.t('settings.multiple_choice_mode'),
        icon: Icons.gamepad,
        iconColor: Colors.purple,
        value: AppState.filter.isButtonMode,
        onChanged: (v) => setState(() {
          AppState.filter.isButtonMode = v;
          PreferencesService.saveConfig();
        }),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t(
          'settings.selected_theme',
          args: [AppState.settings.darkTheme ? 'Dark' : 'Light'],
        ),
        icon: isDark ? Icons.dark_mode : Icons.light_mode,
        iconColor: isDark ? Colors.amber : Colors.orange,
        value: AppState.settings.darkTheme,
        onChanged: (v) {
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
    // --- MIGRATION (ESKİ VERİYİ KURTARMA) ---
    // Eğer kayıtlı dil listede yoksa (örn: "Türkçe" geldiyse), onu koda ('tr') çevir.
    String currentValue = AppState.settings.language;

    if (!Localization.supportedLanguages.contains(currentValue)) {
      if (currentValue == 'Türkçe') {
        currentValue = 'tr';
      } else {
        currentValue = 'en';
      }

      // Hatayı düzelttik, bunu hemen hafızaya da kaydedelim ki bir daha sormasın
      AppState.settings.language = currentValue;
      PreferencesService.saveConfig();
    }
    // ----------------------------------------

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.language, color: Colors.blue),
      ),
      title: Text(
        Localization.t('settings.lang'),
        style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue, // Artık güvenli değeri kullanıyoruz
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          dropdownColor: isDark ? Colors.grey[850] : Colors.white,
          items: Localization.supportedLanguages
              .map((String code) => DropdownMenuItem(
            value: code,
            child: Text(
              Localization.getDisplayName(code),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => AppState.settings.language = v);
              PreferencesService.saveConfig();

              // Dil değişince uygulamayı yeniden başlatmak veya UI'ı yenilemek iyi fikirdir
              restartApp(context);
            }
          },
        ),
      ),
    );
  }

  // --- BÖLÜM 3: KITALAR ---

  Widget _buildContinentSettings(bool isDark) {
    return _buildSettingsContainer(isDark, [
      _buildSwitchTile(
        title: Localization.t('settings.continents.europe'),
        icon: Icons.public,
        iconColor: Colors.blue,
        value: AppState.filter.europe,
        onChanged: (v) => _updateContinent(() => AppState.filter.europe = v),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t('settings.continents.asia'),
        icon: Icons.temple_buddhist, // Asya için temsili
        iconColor: Colors.red,
        value: AppState.filter.asia,
        onChanged: (v) => _updateContinent(() => AppState.filter.asia = v),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t('settings.continents.africa'),
        icon: Icons.landscape,
        iconColor: Colors.orange,
        value: AppState.filter.africa,
        onChanged: (v) => _updateContinent(() => AppState.filter.africa = v),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t('settings.continents.north_america'),
        icon: Icons.location_city,
        iconColor: Colors.green,
        value: AppState.filter.northAmerica,
        onChanged: (v) => _updateContinent(() => AppState.filter.northAmerica = v),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t('settings.continents.south_america'),
        icon: Icons.forest, // Amazon ormanları temsili
        iconColor: Colors.green.shade800,
        value: AppState.filter.southAmerica,
        onChanged: (v) => _updateContinent(() => AppState.filter.southAmerica = v),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t('settings.continents.oceania'),
        icon: Icons.surfing,
        iconColor: Colors.cyan,
        value: AppState.filter.oceania,
        onChanged: (v) => _updateContinent(() => AppState.filter.oceania = v),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t('settings.continents.antarctica'),
        icon: Icons.ac_unit,
        iconColor: Colors.lightBlueAccent,
        value: AppState.filter.antarctic,
        onChanged: (v) => _updateContinent(() => AppState.filter.antarctic = v),
      ),
      _buildDivider(isDark),
      _buildSwitchTile(
        title: Localization.t('settings.un_members'),
        icon: Icons.flag_circle,
        iconColor: Colors.indigo,
        value: AppState.filter.includeNonUN,
        onChanged: (v) => _updateContinent(() => AppState.filter.includeNonUN = v),
      ),
    ]);
  }

  void _updateContinent(VoidCallback action) {
    setState(() {
      action();
      PreferencesService.saveConfig();
    });
  }

  // --- YARDIMCI WIDGETLAR (Reusable Components) ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60, // İkonun hizasından başlasın
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildVersionInfo(bool isDark) {
    return Center(
      child: Text(
        AppState.version,
        style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 12),
      ),
    );
  }

  Future<void> _showContinentWarning() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Text(Localization.t('settings.continent_warning_title')),
          ],
        ),
        content: Text(
          "${Localization.t('settings.no_continent_active')}\n\n${Localization.t('settings.activate_continent_prompt')}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localization.t('common.ok'), style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}