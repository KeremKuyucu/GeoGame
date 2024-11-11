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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                'GeoGame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(
                Yazi.get('sikayet'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.share, color: Color(0xFF5865F2)),
              title: Text(Yazi.get('uygpaylas')),
              onTap: () async {
                await Share.share(Yazi.get('davetpromt'));
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.instagram),
              title: Text(Yazi.get('instagram')),
              onTap: () async {
                await EasyLauncher.url(
                    url: Yazi.get('instagramurl'), mode: Mode.platformDefault);
              },
            ),
            ListTile(
              leading: Icon(Icons.public, color: Colors.red),
              title: Text(Yazi.get('website')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('websiteurl'));
              },
            ),
            ListTile(
              leading: FaIcon(Icons.report),
              title: Text(Yazi.get('hatabildir')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('hatabildirurl'));
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.github),
              title: Text(Yazi.get('github')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('githuburl'));
              },
            ),
            ListTile(
              leading: Icon(Icons.discord, color: Color(0xFF5865F2)),
              title: Text(Yazi.get('discord')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('discordurl'));
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.red),
              title: Text(Yazi.get('sarki')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('sarkiurl'));
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                Yazi.get('yapimci'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            SizedBox(height: 20), // Boşluk bırakır
          ],
        ),
      ),
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
                kalici.isim, // Ülke ismi Türkçe veya İngilizce olabilir.
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
