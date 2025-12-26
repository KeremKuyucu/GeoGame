import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/auth_service.dart';
import 'package:geogame/screens/mainscreen/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geogame/services/localization_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Odak yönetimi için FocusNode'lar eklendi
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// 🌟 GİRİŞ İŞLEMİ VE YÖNLENDİRME MANTIĞI
  Future<void> _handleLogin() async {
    // 1. Autofill Context'i Kapat (Tarayıcıya "işlem bitti, şifreyi kaydetmeyi teklif et" sinyali)
    // shouldSave: true parametresi web için kritiktir.
    TextInput.finishAutofillContext(shouldSave: true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(Localization.get('boslukuyari'), Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final String? error = await AuthService.signIn(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error == null) {
      _showSnackBar(Localization.get('girisbasarili'), Colors.green);

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }

      AppState.selectedIndex = 0;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      _showSnackBar(error, Colors.red);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('giris')),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: Center( // Web'de geniş ekranlarda ortalamak için Center eklendi
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            // Web için maksimum genişlik kısıtlaması (Estetik görünüm için)
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
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
                  SizedBox(height: 50),
                  _buildLoginCard(),
                  SizedBox(height: 30),
                  _buildRegisterSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: AppState.settings.darkTheme
                ? [Colors.grey.shade900, Colors.black87]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AutofillGroup(
          // onDisposeAction: AutofillContextAction.commit, // Bazı durumlarda işe yarar
          child: Column(
            children: [
              _buildTextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: Localization.get('eposta'),
                icon: Icons.email,
                obscure: false,
                autofillHints: const [AutofillHints.email],
                // E-posta girildikten sonra "İleri" tuşuna basılınca şifreye geç
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: Localization.get('sifre'),
                icon: Icons.lock,
                obscure: true,
                autofillHints: const [AutofillHints.password],
                // Şifre girildikten sonra "Bitti/Enter" tuşuna basılınca girişi tetikle
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: 30),

              if (_isLoading)
                CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      Localization.get('giris'),
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
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Column(
      children: [
        Text(
          Localization.get('loginmesaj1'),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 10),
        TextButton.icon(
          onPressed: _openWebAuth,
          icon: Icon(Icons.open_in_browser),
          label: Text(Localization.get('loginmesaj2')),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    FocusNode? focusNode,
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: autofillHints?.contains(AutofillHints.email) == true
          ? TextInputType.emailAddress
          : TextInputType.text,
      autofillHints: autofillHints,
      textInputAction: textInputAction, // Klavye aksiyonu (İleri/Bitti)
      onSubmitted: onSubmitted, // Enter tuşu tetikleyicisi
      style: TextStyle(color: AppState.settings.darkTheme ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppState.settings.darkTheme ? Colors.white70 : Colors.grey[700]),
        labelStyle: TextStyle(color: AppState.settings.darkTheme ? Colors.white70 : Colors.grey[700]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppState.settings.darkTheme ? Colors.white30 : Colors.grey[400]!),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: AppState.settings.darkTheme ? Colors.grey[850] : Colors.grey[100],
      ),
    );
  }
}