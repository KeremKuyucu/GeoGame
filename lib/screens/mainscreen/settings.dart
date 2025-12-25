import 'package:flutter/material.dart';
import 'package:geogame/util.dart';
import 'package:geogame/screens/auth/authpage.dart'; // LoginPage'in olduğu dosya
import 'package:url_launcher/url_launcher.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../data/app_context.dart';
import '../../data/bottomBar.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart'; // ✅ EKLENDİ

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ❌ Supabase instance kaldırıldı. UI veritabanını bilmemeli.

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    // 1. Oturum durumunu Service üzerinden kontrol et
    // Bu işlem global değişkenleri (uid, name, puanlar) günceller.
    await AuthService.checkSession();

    // 2. UI'ı güncelle ki yeni veriler görünsün
    if (mounted) setState(() {});

    // 3. Kıta kontrolü
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

  void _selectIndex(int index) {
    if (index == AppState.selectedIndex) return;
    setState(() => AppState.selectedIndex = index);

    Widget page;
    switch (index) {
      case 0: page = GeoGameLobi(); break;
      case 1: page = Leadboard(); break;
      case 2: page = Profiles(); break;
      case 3: return;
      default: page = GeoGameLobi();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  void restartApp() {
    AppState.selectedIndex = 0;
    Localization.loadLocalization(AppState.settings.language);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GeoGameLobi()));
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
        onTap: (index) {
          if (getFilteredCountries().length > 0 || index == 3) {
            _selectIndex(index);
          } else {
            _kitaUyari();
          }
        },
        items: navBarItems,
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
        SizedBox(height: 8),
        Text(
          '${Localization.get('toplampuan')}: $toplampuan',
          style: TextStyle(
            fontSize: 16,
            color: AppState.settings.darkTheme ? Colors.white70 : Colors.grey[700],
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
            StorageService.saveLocalData();
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
              StorageService.saveLocalData();
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
                StorageService.saveLocalData();
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
          Localization.get('sadecebm'),
          sadecebm,
              (v) => setState(() {
            sadecebm = v;
            StorageService.saveLocalData();
          }),
        ),
        _switchRow(
          Localization.get('amerika'),
          amerikakitasi,
              (v) => setState(() {
            amerikakitasi = v;
            StorageService.saveLocalData();
          }),
        ),
        _switchRow(
          Localization.get('asya'),
          asyakitasi,
              (v) => setState(() {
            asyakitasi = v;
            StorageService.saveLocalData();
          }),
        ),
        _switchRow(
          Localization.get('afrika'),
          afrikakitasi,
              (v) => setState(() {
            afrikakitasi = v;
            StorageService.saveLocalData();
          }),
        ),
        _switchRow(
          Localization.get('avrupa'),
          avrupakitasi,
              (v) => setState(() {
            avrupakitasi = v;
            StorageService.saveLocalData();
          }),
        ),
        _switchRow(
          Localization.get('okyanusya'),
          okyanusyakitasi,
              (v) => setState(() {
            okyanusyakitasi = v;
            StorageService.saveLocalData();
          }),
        ),
        _switchRow(
          Localization.get('bmuyelik'),
          bmuyeligi,
              (v) => setState(() {
            bmuyeligi = v;
            StorageService.saveLocalData();
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
            activeColor: Colors.green,
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