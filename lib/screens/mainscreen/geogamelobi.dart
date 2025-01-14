import 'package:GeoGame/util.dart';
import 'package:http/http.dart' as http;

void disableCertificateVerification() {
  HttpOverrides.global = MyHttpOverrides();
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;  // Sertifika doğrulamasını geç
    return client;
  }
}

class GeoGameLobi extends StatefulWidget {
  @override
  _GeoGameLobiState createState() => _GeoGameLobiState();
}

class _GeoGameLobiState extends State<GeoGameLobi> {
  int _selectedOption = 0;
  List<String> options = List.filled(3, '');
  @override
  void initState() {
    super.initState();
    _initializeGame();
    if (darktema)
      ThemeModeBuilderConfig.setDark();
    else
      ThemeModeBuilderConfig.setLight();
  }
  Future<void> _initializeGame() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await readFromFile((update) => setState(update));
    await dilDegistir();
    await surumkiyasla();
    istatistik(context);
  }
  Future<void> dilDegistir() async {
    await Yazi.loadDil(secilenDil).then((_) {
      setState(() {
        navBarItems = [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: Text(Yazi.get('navigasyonbar1')),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.leaderboard),
            title: Text(Yazi.get('navigasyonbar2')),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: const Icon(FontAwesomeIcons.info),
            selectedColor: Colors.teal,
            title: Text(Yazi.get('navigasyonbar3')),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: Text(Yazi.get('navigasyonbar4')),
            selectedColor: Colors.teal,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: Text(Yazi.get('navigasyonbar5')),
            selectedColor: Colors.orange,
          ),
        ];
      });
    });
    isEnglish = (secilenDil != 'Türkçe');
  }
  Future<void> surumkiyasla() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String? remoteVersion;
    String? apkUrl;

    Future<void> _fetchData() async {
      try {
        final response = await http.get(Uri.parse(
            'https://raw.githubusercontent.com/keremlolgg/GeoGame/main/latest_version.json'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Null kontrolü ve verinin geçerliliği
          if (data != null && data.containsKey('latest_version') && data.containsKey('apk_url') && data.containsKey('apiserver')) {
            setState(() {
              remoteVersion = data['latest_version'] ?? 'N/A';
              apkUrl = data['apk_url'] ?? 'N/A';
              apiserver = data['apiserver'] ?? 'N/A';
            });
          } else {
            throw Exception('Missing keys in the JSON data');
          }
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    await _fetchData();
    void showUpdateDialog(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Yazi.get('surum1')),
            content: Text(Yazi.get('surum2')),
            actions: <Widget>[
              TextButton(
                child: Text(Yazi.get('surum3')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(Yazi.get('surum4')),
                onPressed: () {
                  Navigator.of(context).pop();
                  EasyLauncher.url(
                    url: apkUrl!,
                  );
                },
              ),
            ],
          );
        },
      );
    }

    if (remoteVersion != null &&
        apkUrl != null &&
        remoteVersion != localVersion) {
      showUpdateDialog(context);
    }
  }
  Future<void> istatistik(BuildContext context) async {
    if (name.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    } else {
      postLeadboard();
    }
  }
  void _selectOption(int index) async {
    setState(() {
      _selectedOption = index;
    });
    if (_selectedOption == 0 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BaskentOyun()),
      );
    } else if (_selectedOption == 1 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BayrakOyun()),
      );
    } else if (_selectedOption == 2 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MesafeOyun()),
      );
    } else if (getSelectableCountryCount() < 1) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }
  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Ulkelerlist()),
      );
    } else if (selectedIndex == 3) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 4 ) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GeoGame',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            // Listelerle yapılandırma
            final titles = [
              Yazi.get('baskenttitle'),
              Yazi.get('bayraktitle'),
              Yazi.get('mesafetitle')
            ];

            final descriptions = [
              Yazi.get('baskentdescription'),
              Yazi.get('bayrakdescription'),
              Yazi.get('mesafedescription')
            ];

            final images = [
              'assets/baskent.jpg',
              'assets/bayrak.jpg',
              'assets/mesafe.jpg'
            ];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  _selectOption(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titles[index],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              descriptions[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
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
          },
        ),
      ),
      drawer: DrawerWidget(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) async {
          setState(() {
            selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}
