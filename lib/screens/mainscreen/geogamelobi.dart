import 'package:GeoGame/util.dart';
import 'package:http/http.dart' as http;

class GeoGameLobi extends StatefulWidget {
  @override
  _GeoGameLobiState createState() => _GeoGameLobiState();
}

class _GeoGameLobiState extends State<GeoGameLobi> {
  int _selectedOption = 0;

  @override
  void initState() {
    super.initState();
    if (darktema)
      ThemeModeBuilderConfig.setDark();
    else
      ThemeModeBuilderConfig.setLight();
    _initializeGame();
  }
  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    setState(() {
      Yazi.dilDegistir();
    });
    yeniulkesec();
    surumKiyasla();
    if (uid.isEmpty) {
      selectedIndex=4;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    } else {
      postLeadboard();
      puanguncelle();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  Future<void> surumKiyasla() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String? remoteVersion;
    String? apkUrl;
    String? updateNotes;

    try {
      final response = await http.get(Uri.parse(
          'https://api.github.com/repos/KeremKuyucu/GeoGame/releases/latest'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        remoteVersion =
            (data['tag_name'] as String?)?.replaceFirst(RegExp(r'^v'), '');
        updateNotes = data['body'] ?? 'Yama notları mevcut değil';

        apkUrl = (data['assets'] as List).firstWhere(
              (asset) =>
              (asset['browser_download_url'] as String).toLowerCase().endsWith('.apk'),
          orElse: () => null,
        )?['browser_download_url'];

        if (remoteVersion != null &&
            apkUrl != null &&
            remoteVersion != localVersion) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(Yazi.get('surum1')),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Yazi.get('surum2')),
                      SizedBox(height: 10),
                      Text(
                        updateNotes ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
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
                      EasyLauncher.url(url: apkUrl!);
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw Exception('GitHub API hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _selectOption(int index) async {
    setState(() {
      _selectedOption = index;
    });
    if (_selectedOption == 0 && getSelectableCountryCount() > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BaskentOyun()),
      );
    } else if (_selectedOption == 1 && getSelectableCountryCount() > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BayrakOyun()),
      );
    } else if (_selectedOption == 2 && getSelectableCountryCount() > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MesafeOyun()),
      );
    } else if (_selectedOption == 3 && getSelectableCountryCount() > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BaskentOyunCoop()),
      );
    } else if (_selectedOption == 4 && getSelectableCountryCount() > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BayrakOyunCoop()),
      );
    }else if (getSelectableCountryCount() < 1) {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 3 ) {
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
          itemCount: 5,
          itemBuilder: (context, index) {
            // Listelerle yapılandırma
            final titles = [
              Yazi.get('baskenttitle'),
              Yazi.get('bayraktitle'),
              Yazi.get('mesafetitle'),
              Yazi.get('baskentcooptitle'),
              Yazi.get('bayrakcooptitle'),
            ];

            final descriptions = [
              Yazi.get('baskentdescription'),
              Yazi.get('bayrakdescription'),
              Yazi.get('mesafedescription'),
              Yazi.get('baskentcoopdescription'),
              Yazi.get('bayrakcoopdescription'),
            ];

            final images = [
              'assets/baskent.jpg',
              'assets/bayrak.jpg',
              'assets/mesafe.jpg',
              'assets/baskent.jpg',
              'assets/bayrak.jpg',
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
