import 'package:flutter/material.dart';
import 'package:geogame/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Supabase'e giriş yap
  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Lütfen tüm alanları doldurun.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Başarılı giriş - Kullanıcı bilgilerini senkronize et
        await _syncUserData(res.user!);

        _showSnackBar('Giriş başarılı!', Colors.green);
        _emailController.clear();
        _passwordController.clear();

        // Callback çağır (ör: Settings sayfasına dön)
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        } else {
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, Colors.red);
    } catch (e) {
      _showSnackBar('Bir hata oluştu: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Kullanıcı verilerini Supabase'den çek ve locale senkronize et
  Future<void> _syncUserData(User authUser) async {
    try {
      // 1️⃣ UID'yi kaydet
      if (mounted) {
        setState(() {
          uid = authUser.id;
        });
      }

      // 2️⃣ Profiles tablosundan kullanıcı bilgilerini çek
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('uid', authUser.id)
          .maybeSingle();

      if (mounted) {
        if (profileData != null) {
          setState(() {
            name = profileData['full_name'] ?? authUser.email?.split('@')[0] ?? 'Oyuncu';
            profilurl = profileData['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';
          });
        } else {
          // Profil yoksa auth metadata'dan al
          setState(() {
            name = authUser.userMetadata?['full_name'] ?? authUser.email?.split('@')[0] ?? 'Oyuncu';
            profilurl = authUser.userMetadata?['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png';
          });

          // ✅ Profil yoksa oluştur
          await _createUserProfile(authUser);
        }
      }

      // 3️⃣ geogame_stats tablosundan istatistikleri çek
      final statsData = await _supabase
          .from('geogame_stats')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (mounted) {
        if (statsData != null) {
          setState(() {
            mesafepuan = (statsData['mesafepuan'] ?? 0) as int;
            bayrakpuan = (statsData['bayrakpuan'] ?? 0) as int;
            baskentpuan = (statsData['baskentpuan'] ?? 0) as int;
            toplampuan = (statsData['puan'] ?? 0) as int;

            mesafedogru = (statsData['mesafedogru'] ?? 0) as int;
            mesafeyanlis = (statsData['mesafeyanlis'] ?? 0) as int;
            bayrakdogru = (statsData['bayrakdogru'] ?? 0) as int;
            bayrakyanlis = (statsData['bayrakyanlis'] ?? 0) as int;
            baskentdogru = (statsData['baskentdogru'] ?? 0) as int;
            baskentyanlis = (statsData['baskentyanlis'] ?? 0) as int;
          });
        } else {
          // ✅ İstatistik yoksa oluştur
          await _createUserStats(authUser.id);

          // Varsayılan değerler
          setState(() {
            mesafepuan = 0;
            bayrakpuan = 0;
            baskentpuan = 0;
            toplampuan = 0;
            mesafedogru = 0;
            mesafeyanlis = 0;
            bayrakdogru = 0;
            bayrakyanlis = 0;
            baskentdogru = 0;
            baskentyanlis = 0;
          });
        }
      }

      // 4️⃣ Tüm verileri locale kaydet
      await writeToFile();

      debugPrint('✅ Kullanıcı verileri başarıyla senkronize edildi!');

    } catch (e) {
      debugPrint('❌ Kullanıcı verisi senkronizasyon hatası: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Senkronizasyon hatası: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// ✅ Kullanıcı profili oluştur (yoksa)
  Future<void> _createUserProfile(User authUser) async {
    try {
      await _supabase.from('profiles').upsert({
        'uid': authUser.id,
        'email': authUser.email,
        'full_name': authUser.userMetadata?['full_name'] ?? authUser.email?.split('@')[0] ?? 'Oyuncu',
        'avatar_url': authUser.userMetadata?['avatar_url'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',
      }, onConflict: 'uid'); // ✅ uid'ye göre güncelle

      debugPrint('✅ Profil oluşturuldu/güncellendi');
    } catch (e) {
      debugPrint('❌ Profil oluşturma hatası: $e');
    }
  }

  /// ✅ Kullanıcı istatistikleri oluştur (yoksa)
  Future<void> _createUserStats(String userId) async {
    try {
      await _supabase.from('geogame_stats').upsert({
        'user_id': userId,
        'puan': 0,
        'mesafepuan': 0,
        'bayrakpuan': 0,
        'baskentpuan': 0,
        'mesafedogru': 0,
        'mesafeyanlis': 0,
        'bayrakdogru': 0,
        'bayrakyanlis': 0,
        'baskentdogru': 0,
        'baskentyanlis': 0,
      }, onConflict: 'user_id'); // ✅ user_id'ye göre güncelle

      debugPrint('✅ İstatistikler oluşturuldu/güncellendi');
    } catch (e) {
      debugPrint('❌ İstatistik oluşturma hatası: $e');
    }
  }

  /// Web tabanlı kayıt sayfasını aç
  Future<void> _openWebAuth() async {
    final Uri url = Uri.parse('https://auth.keremkk.com.tr');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Site açılamadı.', Colors.red);
    }
  }

  /// SnackBar göster
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              // Logo veya başlık
              Icon(
                Icons.public,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 20),
              Text(
                'GeoGame',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Hesabınıza giriş yapın',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 50),

              // Login Card
              _buildLoginCard(),

              SizedBox(height: 30),

              // Kayıt ol linki
              _buildRegisterSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Giriş kartı
  Widget _buildLoginCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: darktema
                ? [Colors.grey.shade900, Colors.black87]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Email alanı
            _buildTextField(
              controller: _emailController,
              label: 'E-posta',
              icon: Icons.email,
              obscure: false,
            ),
            SizedBox(height: 20),

            // Şifre alanı
            _buildTextField(
              controller: _passwordController,
              label: 'Şifre',
              icon: Icons.lock,
              obscure: true,
            ),
            SizedBox(height: 30),

            // Giriş butonu
            if (_isLoading)
              CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Giriş Yap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Kayıt ol bölümü
  Widget _buildRegisterSection() {
    return Column(
      children: [
        Text(
          'Hesabınız yok mu?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 10),
        TextButton.icon(
          onPressed: _openWebAuth,
          icon: Icon(Icons.open_in_browser),
          label: Text('Web sitesinden kayıt olun'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ],
    );
  }

  /// TextField bileşeni
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        color: darktema ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: darktema ? Colors.white70 : Colors.grey[700],
        ),
        labelStyle: TextStyle(
          color: darktema ? Colors.white70 : Colors.grey[700],
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: darktema ? Colors.white30 : Colors.grey[400]!,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: darktema ? Colors.grey[850] : Colors.grey[100],
      ),
    );
  }
}