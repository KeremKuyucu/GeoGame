import 'package:geogame/util.dart';

class Userprofile extends StatefulWidget {
  final int userindex;
  Userprofile({Key? key, required this.userindex}) : super(key: key);
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<Userprofile> {
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Güvenlik kontrolü: users listesi boş veya index geçersizse
    if (users.isEmpty || widget.userindex < 0 || widget.userindex >= users.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(Yazi.get('navigasyonbar2')),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Kullanıcı bulunamadı',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Seçili kullanıcının verilerini al
    final user = users[widget.userindex];

    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('navigasyonbar2')),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 15.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            shadowColor: Colors.black.withOpacity(0.3),
            color: Colors.grey.shade800,
            child: Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil başlığı
                  Row(
                    children: [
                      // Profil Resmi
                      CircleAvatar(
                        radius: 35.0,
                        backgroundImage: NetworkImage(
                          user['profilurl'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',
                        ),
                        backgroundColor: Colors.grey,
                      ),
                      SizedBox(width: 16.0),
                      // Kullanıcı adı
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? 'Anonim Oyuncu',
                              style: TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sıralama: #${widget.userindex + 1}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.amber,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6),
                    thickness: 1.2,
                  ),
                  SizedBox(height: 10.0),

                  // Toplam Puan
                  Text(
                    '${Yazi.get('profil1')} ${user['puan'] ?? 0}',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10.0),

                  // Mesafe İstatistikleri
                  Divider(
                    color: Colors.white.withOpacity(0.6),
                    thickness: 1.2,
                  ),
                  _buildStatRow(
                    Yazi.get('profil2'),
                    '${user['mesafepuan'] ?? 0}',
                    Colors.tealAccent,
                  ),
                  _buildStatRow(
                    Yazi.get('profil3'),
                    '${user['mesafedogru'] ?? 0}',
                    Colors.green,
                  ),
                  _buildStatRow(
                    Yazi.get('profil4'),
                    '${user['mesafeyanlis'] ?? 0}',
                    Colors.red,
                  ),
                  SizedBox(height: 10.0),

                  // Bayrak İstatistikleri
                  Divider(
                    color: Colors.white.withOpacity(0.6),
                    thickness: 1.2,
                  ),
                  _buildStatRow(
                    Yazi.get('profil5'),
                    '${user['bayrakpuan'] ?? 0}',
                    Colors.tealAccent,
                  ),
                  _buildStatRow(
                    Yazi.get('profil6'),
                    '${user['bayrakdogru'] ?? 0}',
                    Colors.green,
                  ),
                  _buildStatRow(
                    Yazi.get('profil7'),
                    '${user['bayrakyanlis'] ?? 0}',
                    Colors.red,
                  ),
                  SizedBox(height: 10.0),

                  // Başkent İstatistikleri
                  Divider(
                    color: Colors.white.withOpacity(0.6),
                    thickness: 1.2,
                  ),
                  _buildStatRow(
                    Yazi.get('profil8'),
                    '${user['baskentpuan'] ?? 0}',
                    Colors.tealAccent,
                  ),
                  _buildStatRow(
                    Yazi.get('profil9'),
                    '${user['baskentdogru'] ?? 0}',
                    Colors.green,
                  ),
                  _buildStatRow(
                    Yazi.get('profil10'),
                    '${user['baskentyanlis'] ?? 0}',
                    Colors.red,
                  ),

                  // ✅ Başarı oranları (opsiyonel)
                  SizedBox(height: 20.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6),
                    thickness: 1.2,
                  ),
                  _buildSuccessRates(user),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ İstatistik satırı widget'ı
  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.0,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Başarı oranlarını hesapla ve göster
  Widget _buildSuccessRates(Map<String, dynamic> user) {
    // Mesafe başarı oranı
    int mesafeTotal = (user['mesafedogru'] ?? 0) + (user['mesafeyanlis'] ?? 0);
    double mesafeRate = mesafeTotal > 0
        ? ((user['mesafedogru'] ?? 0) / mesafeTotal * 100)
        : 0;

    // Bayrak başarı oranı
    int bayrakTotal = (user['bayrakdogru'] ?? 0) + (user['bayrakyanlis'] ?? 0);
    double bayrakRate = bayrakTotal > 0
        ? ((user['bayrakdogru'] ?? 0) / bayrakTotal * 100)
        : 0;

    // Başkent başarı oranı
    int baskentTotal = (user['baskentdogru'] ?? 0) + (user['baskentyanlis'] ?? 0);
    double baskentRate = baskentTotal > 0
        ? ((user['baskentdogru'] ?? 0) / baskentTotal * 100)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Başarı Oranları',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        _buildProgressBar('Mesafe', mesafeRate, Colors.tealAccent),
        SizedBox(height: 8),
        _buildProgressBar('Bayrak', bayrakRate, Colors.orangeAccent),
        SizedBox(height: 8),
        _buildProgressBar('Başkent', baskentRate, Colors.purpleAccent),
      ],
    );
  }

  /// ✅ İlerleme çubuğu
  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}