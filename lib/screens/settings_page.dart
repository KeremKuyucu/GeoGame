import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:GeoGame/screens/geogamelobi.dart';
import "package:theme_mode_builder/theme_mode_builder.dart";

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedTheme = 'Light';
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      _selectedTheme = value ? 'Dark' : 'Light'; // Temayı güncelle
    });
  }
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
  void restartApp() {
    Yazi.loadDil(isEnglish ? 'en' : 'tr');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GeoGameLobi()),
    );
  }
  Future<void> _showMyDialog() async {
    Yazi.loadDil(isEnglish ? 'en' : 'tr');
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(16.0),
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Container(
                  color: Colors.grey.shade800,
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Text(
                        Yazi.get('ayarlarlist10'),
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
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
              buildSwitch(Yazi.get('ayarlarlist11'), isEnglish, (value) {
                setState(() {
                  isEnglish = value;
                  writeToFile();
                });
                restartApp();
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
            ],
          ),
        ),
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
