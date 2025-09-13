import 'package:GeoGame/util.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Timer? _clipboardTimer;

  @override
  void initState() {
    super.initState();
    readFromFile((update) => setState(update));
    if (getSelectableCountryCount() < 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _kitaUyari();
      });
    }
  }
  void dispose() {
    _clipboardTimer?.cancel();
    super.dispose();
  }
  void _startClipboardTimer() {
    _clipboardTimer = Timer.periodic(Duration(seconds: 2), _checkClipboard);
  }
  void _stopClipboardTimer() {
    _clipboardTimer?.cancel();
    _clipboardTimer = null;
  }
  void _checkClipboard(Timer timer) async {
    if (uid.isNotEmpty) {
      _stopClipboardTimer();
      return;
    }

    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    String? text = clipboardData?.text;
    if (text != null && text.isNotEmpty) {
      try {
        var jsonData = jsonDecode(text);
        if (jsonData is Map && jsonData.containsKey('user') && jsonData['user'] is Map) {
          var user = jsonData['user'];
          setState(() {
            uid = user['uid'];
            name = user['displayName'];
            profilurl = user['profilePicture'];
            writeToFile();
            puanguncelle();
            Clipboard.setData(ClipboardData(text: ''));
          });

          debugPrint('Geçerli JSON verisi: $jsonData');
          debugPrint('UID: $uid');
          debugPrint('Display Name: $name');
          debugPrint('Profile Picture: $profilurl');
          _stopClipboardTimer();
        } else {
          debugPrint('Geçerli JSON verisi değil.');
        }
      } catch (e) {
        debugPrint('Geçerli bir JSON verisi değil: $e');
      }
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
  void restartApp() {
    selectedIndex = 0;
    Yazi.loadDil(secilenDil);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GeoGameLobi()),
    );
  }
  Future<void> _kitaUyari() async {
    Yazi.loadDil(secilenDil);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kitayari')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('kitayari1')),
                Text(Yazi.get('kitayari2')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Yazi.get('tamam')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> signOut() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$name" adlı hesaptan çıkış yaptınız.'),
      ),
    );
    try {
      final targetUrl = 'https://geogame-api.keremkk.com.tr/api/geogamesignlog';
      final response = await http
          .post(
            Uri.parse(targetUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'uid': uid,
              'name': name,
            }),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint('Mesaj başarıyla gönderildi!');
      } else {
        debugPrint('Mesaj gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Hata: $e');
    }
    setState(() {
      name = '';
      uid = '';
      profilurl = 'https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363';
      toplampuan = 0;
      mesafepuan = 0;
      baskentpuan = 0;
      bayrakpuan = 0;
      mesafedogru = 0;
      baskentdogru = 0;
      bayrakdogru = 0;
      mesafeyanlis = 0;
      baskentyanlis = 0;
      bayrakyanlis = 0;
      writeToFile();
    });
    _startClipboardTimer();
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
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 12.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  shadowColor: Colors.black.withOpacity(0.3),
                  color: Colors.grey.shade900,
                  child: Container(
                    padding: const EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade800, Colors.black87],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (uid.isEmpty) ...[
                          ElevatedButton(
                            onPressed: () {
                              _startClipboardTimer();
                              EasyLauncher.url(url: 'https://geogame-auth.keremkk.com.tr');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 14.0),
                              elevation: 5,
                            ),
                            child: Text(
                              Yazi.get('giris'),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            Yazi.get('oturummesaj'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ] else ...[
                          AnimatedContainer(
                            duration: Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            height: 110.0,
                            width: 110.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(profilurl),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10.0,
                                  spreadRadius: 1.5,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: signOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 14.0),
                              elevation: 5,
                            ),
                            child: Text(
                              Yazi.get('cikis'),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ), // oturum açma
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Yazi.get('digerayarlar'),
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ), // baslık
              buildSwitch(Yazi.get('siklimod'), yazmamodu, (value) {
                setState(() {
                  yazmamodu = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('tema') + (darktema ? 'Dark' : 'Light'), darktema, (value) {
                setState(() {
                  darktema = value;
                  if (darktema)
                    ThemeModeBuilderConfig.setDark();
                  else
                    ThemeModeBuilderConfig.setLight();
                  writeToFile();
                });
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Yazi.get('dil'), style: TextStyle(fontSize: 16.0)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: DropdownButton<String>(
                        hint: Text(secilenDil),
                        isExpanded: true,
                        items: diller.map((String dil) {
                          return DropdownMenuItem<String>(
                            value: dil,
                            child: Text(dil),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            secilenDil = value.toString();
                            writeToFile();
                          });
                          restartApp();
                        },
                      ),
                    ),
                  ),
                ],
              ), // dil değiştirme
              if (secilenDil != "Türkçe")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'If there is a translation error,',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'please report the error.',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'The translations are machine translations.',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ), // makine çeviri uyarısı
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Yazi.get('kitasecenek'),
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ), // baslık
              buildSwitch(Yazi.get('sadecebm'), sadecebm, (value) {
                setState(() {
                  sadecebm = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('amerika'), amerikakitasi, (value) {
                setState(() {
                  amerikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('asya'), asyakitasi, (value) {
                setState(() {
                  asyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('afrika'), afrikakitasi, (value) {
                setState(() {
                  afrikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('avrupa'), avrupakitasi, (value) {
                setState(() {
                  avrupakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('okyanusya'), okyanusyakitasi, (value) {
                setState(() {
                  okyanusyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('antartika'), antartikakitasi, (value) {
                setState(() {
                  antartikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('bmuyelik'), bmuyeligi, (value) {
                setState(() {
                  bmuyeligi = value;
                  writeToFile();
                });
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            if (getSelectableCountryCount() > 0) selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}

Widget buildSwitch( String title, bool currentValue, ValueChanged<bool> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16.0)),
        Switch(
          value: currentValue,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveTrackColor: Colors.grey,
          inactiveThumbColor: Colors.red,
        ),
      ],
    ),
  );
}
