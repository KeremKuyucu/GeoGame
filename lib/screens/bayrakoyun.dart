import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:searchfield/searchfield.dart';

class BayrakOyun extends StatefulWidget {
  @override
  _BayrakOyunState createState() => _BayrakOyunState();
}

class _BayrakOyunState extends State<BayrakOyun> {
  final List<Color> buttonColors = [
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.red
  ];
  late TextEditingController _controller;
  String _currentInput = '';
  int puan = 50;
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
    yeniulkesec();
    bayrakoyunkurallari();
  }

  Future<void> bayrakoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('bayrakkural')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('bayrakkural1')),
                Text(Yazi.get('bayrakkural2')),
                Text(Yazi.get('bayrakkural3')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Yazi.get('bayrakkural4')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Yazi.get('dogrucevap')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          toplampuan += puan;
          writeToFile();
        });
        puan = 50;
      } else {
        puan -= 10;
        if (puan < 20) puan = 20;
        Yanlis();
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
        content: Text(Yazi.get('yazilan') + kalici.isim),
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
        title: Text(Yazi.get('bayrak')),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                          void _checkAnswer() {
                            setState(() {
                              if (kalici
                                  .ks(kelimeDuzelt(_controller.text.trim()))) {
                                _controller.clear();
                                yeniulkesec();
                                Dogru();
                                setState(() {
                                  toplampuan += puan;
                                  writeToFile();
                                });
                              } else {
                                puan -= 10;
                                if (puan < 20) puan = 20;
                                Yanlis();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(Yazi.get('yanlis')),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            });
                          }

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
    );
  }
}
