import 'package:flutter/material.dart';
import 'package:geogame/screens/auth/authpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:theme_mode_builder/theme_mode_builder.dart';
import 'dart:async';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/bottomBar.dart';
import 'package:geogame/models/drawer_widget.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/services/preferences_service.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:geogame/screens/leadboards-and-profile/leadboard.dart';
import 'package:geogame/screens/profiles/profiles.dart';




class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
if (getFilteredCountries().length < 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _kitaUyari();
      });
    }
  }

  // --- AUTH İŞLEMLERİ (Artık Tek Satır) ---

  Future<void> _signOut() async {
    // Tüm kirli işi Service halleder (Supabase çıkış + Yerel sıfırlama)
    await AuthService.signOut();

    if (mounted) {
      setState(() {}); // UI'ı yenile (Misafir moduna döner)
      _showSnackBar(Localization.get('cikisbasarili'), Colors.green);
    }
  }

  // --- YARDIMCI METODLAR ---

  Future<void> _openWebAuth() async {
    final Uri url = Uri.parse('https://auth.keremkk.com.tr');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar(Localization.get('siteuyari'), Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void restartApp() {
    AppState.selectedIndex = 0;
    Localization.languageLoad();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onLoginSuccess: () {
            // Giriş başarılı olduğunda sayfayı yenile
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('ayarlar')),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAccountCard(),
              SizedBox(height: 20),
              _buildGeneralSettings(),
              _buildContinentSettings(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: AppState.selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        items: navBarItems,

        // ✅ Tüm mantık burada
        onTap: (index) {
          // 1. Zaten aynı sayfadaysak HİÇBİR ŞEY YAPMA (Buradan çık)
          if (AppState.selectedIndex == index) return;

          // 2. Değilsek, seçili indexi güncelle (Rengi değiştirir)
          setState(() {
            AppState.selectedIndex = index;
          });

          // 3. Hangi sayfaya gidileceğini belirle
          Widget page;
          switch (index) {
            case 0:
              page = MainScreen();
              break;
            case 1:
              page = Leadboard();
              break;
            case 2:
              page = Profiles();
              break;
            case 3:
              page = SettingsPage();
              break;
            default:
              return;
          }

          // 4. Sayfaya git (Animasyonsuz geçiş en iyisidir)
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => page,
              transitionDuration: Duration.zero, // Anında geçiş
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

  // --- UI BİLEŞENLERİ ---

  Widget _buildAccountCard() {
    // Burada AppState.user.isLoggedIn kullanmak daha modern olurdu
    // ama senin mevcut global değişken yapına dokunmuyorum:
    return Card(
      elevation: 12.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
            colors: AppState.settings.darkTheme
                ? [Colors.grey.shade900, Colors.black87]
                : [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: !AuthService.isAuthenticated ? _buildGuestUI() : _buildProfileUI(),
      ),
    );
  }

  Widget _buildGuestUI() {
    return Column(
      children: [
        Icon(
          Icons.account_circle,
          size: 80,
          color: AppState.settings.darkTheme ? Colors.white38 : Colors.grey[400],
        ),
        SizedBox(height: 15),
        Text(
          Localization.get('misafir'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppState.settings.darkTheme ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        Text(
          Localization.get('girisaciklama'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppState.settings.darkTheme ? Colors.white70 : Colors.grey[700],
          ),
        ),
        SizedBox(height: 25),
        ElevatedButton.icon(
          onPressed: _navigateToLogin,
          icon: Icon(Icons.login),
          label: Text(Localization.get('giris')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
        ),
        SizedBox(height: 15),
        TextButton(
          onPressed: _openWebAuth,
          child: Text(
            Localization.get('kayitol'),
            style: TextStyle(
              color: AppState.settings.darkTheme ? Colors.white70 : Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileUI() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(AppState.user.avatarUrl),
          backgroundColor: Colors.white10,
        ),
        SizedBox(height: 12),
        Text(
          AppState.user.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppState.settings.darkTheme ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _openWebAuth,
          icon: Icon(Icons.edit, color: Colors.blueAccent),
          label: Text(Localization.get('profilduzenleme')),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blueAccent),
            foregroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _signOut, // ✅ AuthService kullanan fonksiyon
          icon: Icon(Icons.logout),
          label: Text(Localization.get('cikis')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.get('digerayarlar'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        _switchRow(
          Localization.get('siklimod'),
          AppState.filter.isButtonMode,
              (v) => setState(() {
                AppState.filter.isButtonMode = v;
                PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('tema') + (AppState.settings.darkTheme ? ' Dark' : ' Light'),
          AppState.settings.darkTheme,
              (v) {
            setState(() {
              AppState.settings.darkTheme = v;
              AppState.settings.darkTheme
                  ? ThemeModeBuilderConfig.setDark()
                  : ThemeModeBuilderConfig.setLight();
              PreferencesService.saveConfig();
            });
          },
        ),
        _buildLanguageSelector(),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Localization.get('dil'), style: TextStyle(fontSize: 16.0)),
          DropdownButton<String>(
            value: AppState.settings.language,
            items: diller
                .map((dil) => DropdownMenuItem(value: dil, child: Text(dil)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => AppState.settings.language = v);
                PreferencesService.saveConfig();
                restartApp();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContinentSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          Localization.get('kitasecenek'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        _switchRow(
          Localization.get('NorthAmerica'),
          AppState.filter.northAmerica,
              (v) => setState(() {
                AppState.filter.northAmerica = v;
                PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('SouthAmerica'),
          AppState.filter.southAmerica,
              (v) => setState(() {
            AppState.filter.southAmerica = v;
            PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('asya'),
          AppState.filter.Asia,
              (v) => setState(() {
                AppState.filter.Asia  = v;
                PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('afrika'),
          AppState.filter.Africa,
              (v) => setState(() {
                AppState.filter.Africa = v;
                PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('avrupa'),
          AppState.filter.Europe,
              (v) => setState(() {
                AppState.filter.Europe = v;
                PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('okyanusya'),
          AppState.filter.Oceania,
              (v) => setState(() {
                AppState.filter.Oceania = v;
                PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('antartika'),
          AppState.filter.Antarctic,
              (v) => setState(() {
                AppState.filter.Antarctic = v;
                PreferencesService.saveConfig();
          }),
        ),
        _switchRow(
          Localization.get('bmuyelik'),
          AppState.filter.includeNonUN,
              (v) => setState(() {
                AppState.filter.includeNonUN = v;
                PreferencesService.saveConfig();
          }),
        ),
      ],
    );
  }

  Widget _switchRow(String title, bool val, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16.0)),
          Switch(
            value: val,
            onChanged: onChanged,
            activeThumbColor: Colors.green, // Yuvarlağın rengi (Açıkken)
            activeTrackColor: Colors.green.withValues(alpha: 0.5), // Çubuğun rengi (Açıkken)
          ),
        ],
      ),
    );
  }

  Future<void> _kitaUyari() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(Localization.get('kitayari')),
        content: Text("${Localization.get('kitayari1')}\n${Localization.get('kitayari2')}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localization.get('tamam')),
          )
        ],
      ),
    );
  }
}