import 'package:GeoGame/util.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
    readFromFile((update) => setState(update));
    if (false == (amerikakitasi || asyakitasi || afrikakitasi || avrupakitasi ||
        okyanusyakitasi || antartikakitasi)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMyDialog();
      });
    }
  }
  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2 || getSelectableCountryCount() == 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Ulkelerlist()),
      );
    } else if (selectedIndex == 3 || getSelectableCountryCount() == 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 4 && getSelectableCountryCount() > 0) {
      // aynı sayfa bişey yapma
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
  Future<void> _showMyDialog() async {
    Yazi.loadDil(secilenDil);
    print(Yazi.get('kitauyari'));
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kitauyari')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('kitauyari1')),
                Text(Yazi.get('kitauyari2')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Yazi.get('kitauyari3')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('ayarlarlist')),
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
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Daha yuvarlak köşeler
                ),
                shadowColor: Colors.black.withOpacity(0.2), // Daha yumuşak gölge
                color: Colors.grey.shade900, // Koyu arka plan rengi
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0), // Container köşelerini yuvarlamak
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade800, Colors.black], // Hafif geçişli renkler
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Yazi.get('ayarlarlist10'),
                            style: TextStyle(
                              fontSize: 18.0, // Daha büyük font
                              fontWeight: FontWeight.bold, // Kalın yazı tipi
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.0), // Metin ile alt kısmı arasına boşluk ekleyin
                          Divider(
                            color: Colors.white.withOpacity(0.5), // Şeffaf beyaz bir çizgi
                          ),
                          // Eğer alt öğeler ekleyecekseniz, buraya ekleyebilirsiniz
                        ],
                      );
                    },
                  ),
                ),
              ),
              _buildSectionTitle(Yazi.get('ayarlarlist12')),
              buildSwitch(Yazi.get('ayarlarlist8'), yazmamodu, (value) {
                setState(() {
                  yazmamodu = value;
                  writeToFile();
                });
              }),
              buildSwitch(
                  Yazi.get('ayarlarlist9'), backgroundMusicPlaying, (value) {
                setState(() {
                  if (backgroundMusicPlaying) {
                    Arkafondurdur();
                    backgroundMusicPlaying = !backgroundMusicPlaying;
                  } else {
                    Arkafon();
                    backgroundMusicPlaying = !backgroundMusicPlaying;
                  }
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist14')+(darktema ? 'Dark': 'Light'), darktema, (value) {
                setState(() {
                  darktema = value;
                  if(darktema)
                    ThemeModeBuilderConfig.setDark();
                  else
                    ThemeModeBuilderConfig.setLight();
                  writeToFile();
                });
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Yazi.get('ayarlarlist11'), style: TextStyle(fontSize: 16.0)),
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('If there is a translation error,'),
                      Text('please report the error.'),
                      Text('The translations are machine translations.'),
                    ],
                  ),
                ],
              ),
              _buildSectionTitle(Yazi.get('ayarlarlist13')),
              buildSwitch(Yazi.get('ayarlarlist1'), amerikakitasi, (value) {
                setState(() {
                  amerikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist2'), asyakitasi, (value) {
                setState(() {
                  asyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist3'), afrikakitasi, (value) {
                setState(() {
                  afrikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist4'), avrupakitasi, (value) {
                setState(() {
                  avrupakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist5'), okyanusyakitasi, (value) {
                setState(() {
                  okyanusyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist6'), antartikakitasi, (value) {
                setState(() {
                  antartikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist7'), bmuyeligi, (value) {
                setState(() {
                  bmuyeligi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('ayarlarlist15'), sadecebm, (value) {
                setState(() {
                  sadecebm = value;
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
            selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildSwitch(String title, bool currentValue,
      ValueChanged<bool> onChanged) {
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
}
