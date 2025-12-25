import 'package:geogame/services/auth_service.dart';
import 'package:geogame/util.dart';
import 'package:http/http.dart' as http;

import '../../data/app_context.dart';
import '../../data/bottomBar.dart';
import '../../services/storage_service.dart';

class GeoGameLobi extends StatefulWidget {
  @override
  _GeoGameLobiState createState() => _GeoGameLobiState();
}

class _GeoGameLobiState extends State<GeoGameLobi> {
  int _selectedOption = 0;

  @override
  void initState() {
    super.initState();
    if (AppState.settings.darkTheme)
      ThemeModeBuilderConfig.setDark();
    else
      ThemeModeBuilderConfig.setLight();
    _initializeGame();
  }
  Future<void> _initializeGame() async {
    await StorageService.loadLocalData();
    if (!mounted) return;
    setState(() {
      Localization.languageSwitch();
    });
    yeniulkesec();
    surumKiyasla();
    if (!mounted) return;
    if (!AuthService.isAuthenticated) {
      AppState.selectedIndex = 4;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
      return;
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> surumKiyasla() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String? remoteVersion;
    String? updateNotes;

    try {
      final response = await http.get(Uri.parse(
          'https://api.github.com/repos/KeremKuyucu/GeoGame/releases/latest'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        remoteVersion =
            (data['tag_name'] as String?)?.replaceFirst(RegExp(r'^v'), '');
        updateNotes = data['body'] ?? 'Yama notları mevcut değil';

        if (remoteVersion != null &&
            remoteVersion != localVersion) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(Localization.get('surum1')),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        updateNotes ?? '',
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(Localization.get('surum2')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(Localization.get('surum3')),
                    onPressed: () {
                      Navigator.of(context).pop();
                      EasyLauncher.url(url: 'https://github.com/KeremKuyucu/GeoGame/releases/latest');
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
    if (_selectedOption == 0 && getFilteredCountries().length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BaskentOyun()),
      );
    } else if (_selectedOption == 1 && getFilteredCountries().length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BayrakOyun()),
      );
    } else if (_selectedOption == 2 && getFilteredCountries().length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MesafeOyun()),
      );
    } else if (getFilteredCountries().length < 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }
  void _selectIndex(int index) async {
    setState(() {
      AppState.selectedIndex = index;
    });
    if (AppState.selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (AppState.selectedIndex == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (AppState.selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (AppState.selectedIndex == 3 ) {
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
              Localization.get('baskenttitle'),
              Localization.get('bayraktitle'),
              Localization.get('mesafetitle'),
            ];

            final descriptions = [
              Localization.get('baskentdescription'),
              Localization.get('bayrakdescription'),
              Localization.get('mesafedescription'),
            ];

            final images = [
              'assets/baskent.jpg',
              'assets/bayrak.jpg',
              'assets/mesafe.jpg',
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
        currentIndex: AppState.selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) async {
          setState(() {
            AppState.selectedIndex = index;
          });
          _selectIndex(AppState.selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}
