import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'dart:io';

class BayrakOyun extends StatefulWidget {

  BayrakOyun();

  @override
  _BayrakOyunState createState() => _BayrakOyunState();
}

class _BayrakOyunState extends State<BayrakOyun> {
  late TextEditingController _controller;
  String suggestedText = '';
  int puan=50;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    await yeniulkesec();
    await playSoundEffect(yenitur);
    await bayrakoyunkurallari();
  }
  Future<bool> _fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }
  void _updateSuggestedText(String text) {
    setState(() {
      suggestedText = bulunanBenzerUlke(kelimeDuzelt(text), ulke);
    });
  }
  Future<void> bayrakoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kurallar'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bayrak Bilme Oyunu'),
                Text('Bayrak Bilme Oyununa hos geldiniz.\nAmaciniz, 250 ulkeden rastgele secilen bir ulkenin bayragini bilmek.'),
                Text('Puan Sistemi: Her turda puaniniz 50 den baslar her yanlis tahminde 10 puan azalir.\n3 Tahminden sonra kazanilan puan 20\'e sabitlenir tur bitince tekrar 50\'den baslar.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
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
        _controller.clear(); // Giriş alanını temizle
        yeniulkesec();
        playSoundEffect(dogru);
        setState(() {
          toplampuan+=puan;
          writeToFile();
        });
      } else {
        puan-=10;
        if(puan<20)
          puan=20;
        playSoundEffect(yanlis);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yanlış cevap. Tekrar deneyin.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _pasButtonPressed() {
    puan=50;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Geçilen Ülke: ${kalici.isim}'),
        backgroundColor: Colors.yellow,
        duration: Duration(seconds: 2),
      ),
    );
    setState(()  {
      yeniulkesec();
      playSoundEffect(yenitur);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bayrak Oyun'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 320,
                child: FutureBuilder<bool>(
                  future: _fileExists(kalici.bayrak),
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.data!) {
                      return Image.network(
                        kalici.url,
                        fit: BoxFit.contain,
                        width: 320,
                      );
                    } else {
                      return Image.asset(
                        kalici.bayrak,
                        fit: BoxFit.contain,
                        width: 320,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) {
                      _updateSuggestedText(text);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tahmininizi girin',
                    ),
                  ),
                ),
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Butonlar arasında eşit boşluk bırakır
            children: [
              ElevatedButton(
                onPressed: _checkAnswer,
                child: Text('Tahmini Kontrol Et'),
              ),
              ElevatedButton(
                onPressed: _pasButtonPressed,
                child: Text('Pas'),
              ),
            ],
          ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.text = bulunanBenzerUlke(kelimeDuzelt(_controller.text.trim()), ulke);
                  });
                },
                child: Text('Şunu mu Demek İstediniz: $suggestedText'),
              ),
              SizedBox(height: 20),
              if (yazmamodu)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var color in [butonAnahtarlar[0], butonAnahtarlar[1]])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _controller.text = color;
                                  _checkAnswer();
                                },
                                child: Text(
                                  color,
                                  style: TextStyle(
                                      color: Colors.black
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color == butonAnahtarlar[0]
                                      ? Colors.green
                                      : Colors.yellow,
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
                        for (var color in [butonAnahtarlar[2], butonAnahtarlar[3]])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _controller.text = color;
                                  _checkAnswer();
                                },
                                child: Text(
                                  color,
                                  style: TextStyle(
                                      color: Colors.black
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color == butonAnahtarlar[2]
                                      ? Colors.blue
                                      : Colors.red,
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
                        Text('Şıkları Ayarlardan Kapatabilirsiniz.'), // Boş bir Text widget
                      ],
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
