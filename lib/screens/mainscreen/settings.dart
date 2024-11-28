import 'package:GeoGame/util.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: name);
    readFromFile((update) => setState(update));
    if (getSelectableCountryCount() < 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _kitaUyari();
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
    } else if (selectedIndex == 2 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Ulkelerlist()),
      );
    } else if (selectedIndex == 3 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 4 || getSelectableCountryCount() < 1) {
      selectedIndex == 4;
      Yenitur();
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
              child: Text(Yazi.get('kitayari3')),
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
          builder: (context) =>
              IconButton(
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
                  borderRadius: BorderRadius.circular(20.0),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
                color: Colors.grey.shade900,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade800, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Yazi.get('isimsorma1'),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Divider(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      SizedBox(height: 8.0),
                      // TextField ile kullanıcıya değer girişi yaptırıyoruz
                      TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: Yazi.get('isimsorma6'),
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            nameChangeNotification(name, _controller.text);
                            if (name.isEmpty)
                              sendNewUserNotification(_controller.text);
                            writeToFile();
                            name = _controller.text;
                          });
                          dogru.play();
                        },
                        child: Text(Yazi.get('isimsorma4')),
                      ),
                    ],
                  ),
                ),
              ), // isim sorma
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Yazi.get('ayarlarlist12'),
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ), // baslık
              buildSwitch(Yazi.get('ayarlarlist8'), yazmamodu, (value) {
                setState(() {
                  yazmamodu = value;
                  writeToFile();
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
              ), // dil değiştirme
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('If there is a translation error,',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Text('please report the error.',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Text('The translations are machine translations.',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ), //makine çeviri uyarı
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Yazi.get('ayarlarlist13'),
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ),// baslık
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
            if (getSelectableCountryCount() > 0)
              selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
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
