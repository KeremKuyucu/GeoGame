import 'package:GeoGame/screens/geogamelobi.dart';
import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:searchfield/searchfield.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BaskentOyun extends StatefulWidget {
  @override
  _BaskentOyunState createState() => _BaskentOyunState();
}

class _BaskentOyunState extends State<BaskentOyun> {
  final List<Color> buttonColors = [
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.red
  ];
  late TextEditingController _controller;
  String _currentInput = '';
  int puan = 50;
  String suggestedText = '';
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _currentInput = _controller.text.trim();
      });
    });
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    await yeniulkesec();
    await baskentoyunkurallari(context);
  }

  Future<void> baskentoyunkurallari(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('baskentkural')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('baskentkural1')),
                Text(Yazi.get('baskentkural2')),
                Text(Yazi.get('baskentkural3')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Yazi.get('baskentkural4')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkAnswer() {
    setState(() {
      if (kalici.ks(kelimeDuzelt(_controller.text.trim()))) {
        _controller.clear();
        _currentInput = '';
        yeniulkesec();
        Dogru();
        baskentdogru++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Yazi.get('dogrucevap')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          baskentpuan += puan;
          writeToFile();
        });
        puan = 50;
      } else {
        puan -= 10;
        if (puan < 20) puan = 20;
        Yanlis();
        baskentyanlis++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Yazi.get('yanliscevap') + puan.toString()),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _pasButtonPressed() {
    puan = 50;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Yazi.get('gecilenulke') + kalici.isim),
        backgroundColor: Colors.yellow,
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      yeniulkesec();
      Yenitur();
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('baskent')),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GeoGameLobi()),
              );
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
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  Yazi.get('baskent1') + kalici.baskent,
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      child: Text(Yazi.get('tahmin')),
                    ),
                    ElevatedButton(
                      onPressed: _pasButtonPressed,
                      child: Text(Yazi.get('pas')),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (yazmamodu)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 0; i < 2; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 4.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _controller.text = butonAnahtarlar[i];
                                    _checkAnswer();
                                  },
                                  child: Text(
                                    butonAnahtarlar[i],
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        buttonColors[i], // Buton rengini ayarla
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 2; i < 4; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 4.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _controller.text = butonAnahtarlar[i];
                                    _checkAnswer();
                                  },
                                  child: Text(
                                    butonAnahtarlar[i],
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        buttonColors[i], // Buton rengini ayarla
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(Yazi.get('sikgizle')),
                        ],
                      )
                    ],
                  ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        SearchField<Ulkeler>(
                          suggestions: ulke
                              .where((e) => (isEnglish ? e.enisim : e.isim)
                                  .toLowerCase()
                                  .contains(_currentInput.toLowerCase()))
                              .map(
                                (e) => SearchFieldListItem<Ulkeler>(
                                  (isEnglish ? e.enisim : e.isim),
                                  item: e,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(e.url),
                                          radius: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            (isEnglish ? e.enisim : e.isim),
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          controller: _controller,
                          onSuggestionTap: (value) {
                            setState(() {
                              _controller.text = value.searchKey;
                              _currentInput = value.searchKey;
                              _checkAnswer();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
