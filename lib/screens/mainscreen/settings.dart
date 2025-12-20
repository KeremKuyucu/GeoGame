import 'package:flutter/material.dart';
import 'package:geogame/util.dart';
import 'package:geogame/screens/auth/authpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  /// Uygulama başladığında yerel verileri yükle ve oturumu doğrula
  Future<void> _initializeSettings() async {
    await readFromFile((update) => setState(update));
    await _checkCurrentUser();

    if (getSelectableCountryCount() < 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _kitaUyari();
      });
    }
  }

  // --- SUPABASE İŞLEMLERİ ---

  Future<void> _checkCurrentUser() async {
    final session = _supabase.auth.currentSession;

    if (session == null || session.user == null) {
      await _handleLocalReset(); // Oturum yoksa merkezi sıfırlama
      return;
    }

    final authUser = session.user!;
    uid = authUser.id;

    // Yerel veriler zaten varsa gereksiz ağ trafiğini engelle
    if (name.isNotEmpty && profilurl != 'https://geogame-cdn.keremkk.com.tr/anon.png') {
      puanguncelle();
      return;
    }

    try {
      final profileData = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('uid', authUser.id)
          .maybeSingle();

      if (mounted && profileData != null) {
        setState(() {
          name = profileData['full_name'] ?? authUser.email?.split('@')[0] ?? 'Oyuncu';
          profilurl = profileData['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';
        });
        await writeToFile();
        puanguncelle();
      }
    } catch (e) {
      debugPrint("Senkronizasyon Hatası: $e");
    }
  }
  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
      await _handleLocalReset(); // Çıkış yapınca merkezi sıfırlama
      _showSnackBar(Yazi.get('cikisbasarili'), Colors.green);
    } catch (e) {
      _showSnackBar(Yazi.get('cikishata'), Colors.red);
    }
  }
  Future<void> _handleLocalReset() async {
    if (!mounted) return;

    setState(() {
      uid = '';
      name = '';
      profilurl = 'https://geogame-cdn.keremkk.com.tr/anon.png';
      mesafedogru = 0; mesafeyanlis = 0;
      bayrakdogru = 0; bayrakyanlis = 0;
      baskentdogru = 0; baskentyanlis = 0;
      mesafepuan = 0; bayrakpuan = 0; baskentpuan = 0;
      toplampuan = 0;
    });

    await writeToFile();
    puanguncelle(); // UI üzerindeki tüm puan hesaplamalarını sıfırla
  }

  // --- YARDIMCI METODLAR ---

  Future<void> _openWebAuth() async {
    final Uri url = Uri.parse('https://auth.keremkk.com.tr');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Site açılamadı.', Colors.red);
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
    if (index == selectedIndex) return;
    setState(() => selectedIndex = index);

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
    selectedIndex = 0;
    Yazi.loadDil(secilenDil);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GeoGameLobi()));
  }

  /// Login sayfasına git
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onLoginSuccess: () {
            setState(() {}); // Settings sayfasını yenile
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('ayarlar')),
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
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          if (getSelectableCountryCount() > 0 || index == 3) {
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
    return Card(
      elevation: 12.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
            colors: darktema
                ? [Colors.grey.shade900, Colors.black87]
                : [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: uid.isEmpty ? _buildGuestUI() : _buildProfileUI(),
      ),
    );
  }

  /// Misafir kullanıcı UI (Giriş yap butonu)
  Widget _buildGuestUI() {
    return Column(
      children: [
        Icon(
          Icons.account_circle,
          size: 80,
          color: darktema ? Colors.white38 : Colors.grey[400],
        ),
        SizedBox(height: 15),
        Text(
          Yazi.get('misafir'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darktema ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        Text(
          Yazi.get('girisaciklama'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: darktema ? Colors.white70 : Colors.grey[700],
          ),
        ),
        SizedBox(height: 25),

        // Giriş Yap Butonu
        ElevatedButton.icon(
          onPressed: _navigateToLogin,
          icon: Icon(Icons.login),
          label: Text(Yazi.get('giris')),
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

        // Kayıt ol linki
        TextButton(
          onPressed: _openWebAuth,
          child: Text(
            Yazi.get('kayitol'),
            style: TextStyle(
              color: darktema ? Colors.white70 : Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  /// Giriş yapmış kullanıcı UI
  Widget _buildProfileUI() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(profilurl),
          backgroundColor: Colors.white10,
        ),
        SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darktema ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${Yazi.get('toplampuan')}: $toplampuan',
          style: TextStyle(
            fontSize: 16,
            color: darktema ? Colors.white70 : Colors.grey[700],
          ),
        ),
        SizedBox(height: 20),

        // Profil düzenle butonu
        OutlinedButton.icon(
          onPressed: _openWebAuth,
          icon: Icon(Icons.edit, color: Colors.blueAccent),
          label: Text(Yazi.get('profilduzenleme')),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blueAccent),
            foregroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        SizedBox(height: 10),

        // Çıkış yap butonu
        ElevatedButton.icon(
          onPressed: _signOut,
          icon: Icon(Icons.logout),
          label: Text(Yazi.get('cikis')),
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
          Yazi.get('digerayarlar'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        _switchRow(
          Yazi.get('siklimod'),
          yazmamodu,
              (v) => setState(() {
            yazmamodu = v;
            writeToFile();
          }),
        ),
        _switchRow(
          Yazi.get('tema') + (darktema ? ' Dark' : ' Light'),
          darktema,
              (v) {
            setState(() {
              darktema = v;
              darktema
                  ? ThemeModeBuilderConfig.setDark()
                  : ThemeModeBuilderConfig.setLight();
              writeToFile();
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
          Text(Yazi.get('dil'), style: TextStyle(fontSize: 16.0)),
          DropdownButton<String>(
            value: secilenDil,
            items: diller
                .map((dil) => DropdownMenuItem(value: dil, child: Text(dil)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => secilenDil = v);
                writeToFile();
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
          Yazi.get('kitasecenek'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        _switchRow(
          Yazi.get('sadecebm'),
          sadecebm,
              (v) => setState(() {
            sadecebm = v;
            writeToFile();
          }),
        ),
        _switchRow(
          Yazi.get('amerika'),
          amerikakitasi,
              (v) => setState(() {
            amerikakitasi = v;
            writeToFile();
          }),
        ),
        _switchRow(
          Yazi.get('asya'),
          asyakitasi,
              (v) => setState(() {
            asyakitasi = v;
            writeToFile();
          }),
        ),
        _switchRow(
          Yazi.get('afrika'),
          afrikakitasi,
              (v) => setState(() {
            afrikakitasi = v;
            writeToFile();
          }),
        ),
        _switchRow(
          Yazi.get('avrupa'),
          avrupakitasi,
              (v) => setState(() {
            avrupakitasi = v;
            writeToFile();
          }),
        ),
        _switchRow(
          Yazi.get('okyanusya'),
          okyanusyakitasi,
              (v) => setState(() {
            okyanusyakitasi = v;
            writeToFile();
          }),
        ),
        _switchRow(
          Yazi.get('bmuyelik'),
          bmuyeligi,
              (v) => setState(() {
            bmuyeligi = v;
            writeToFile();
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
        title: Text(Yazi.get('kitayari')),
        content: Text("${Yazi.get('kitayari1')}\n${Yazi.get('kitayari2')}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Yazi.get('tamam')),
          )
        ],
      ),
    );
  }
}