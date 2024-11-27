import 'package:GeoGame/util.dart';

class UlkelerProfiles extends StatefulWidget {
  @override
  _UlkelerProfilesState createState() => _UlkelerProfilesState();
}

class _UlkelerProfilesState extends State<UlkelerProfiles> {
  @override
  void initState() {
    super.initState();
    setState(() {
      _initializeGame();
    });
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ulkeler'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              // Ülke Adı
              Text(
                isEnglish ? kalici.enisim : kalici.isim,
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 12.0),
              Divider(
                color: Colors.white.withOpacity(0.6),
                thickness: 1.2,
              ),
              SizedBox(height: 10.0),

              // Ülke Başkenti
              Text(
                'Başkenti: ${kalici.baskent}', // Ülkenin başkent bilgisi
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),

              // Ülkenin Kıtası
              Text(
                'Kıta: ${kalici.kita}',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),

              // BM Üyesi Olma Durumu
              Text(
                'BM Üyesi: ${kalici.bm ? 'Evet' : 'Hayır'}',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.0),

              // Enlem ve Boylam Bilgisi
              Text(
                'Ondalıklı Kordinat:',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white70,
                ),
              ),
              Text(
                'Enlem: ${kalici.enlem}, Boylam: ${kalici.boylam}',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 10.0),
              SizedBox(
                width: 320,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 320,
                      child: Image.asset(
                        kalici.bayrak,
                        fit: BoxFit.contain,
                        width: 320,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            kalici.url,
                            fit: BoxFit.contain,
                            width: 320,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  'İnternet Hatası\n Pas tuşuna pas düzelmiyorsa internetini kontrol et.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
