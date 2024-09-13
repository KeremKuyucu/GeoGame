import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'dart:io';
import 'package:searchfield/searchfield.dart';

class BayrakOyun extends StatefulWidget {

  BayrakOyun();

  @override
  _BayrakOyunState createState() => _BayrakOyunState();
}

class _BayrakOyunState extends State<BayrakOyun> {
  late TextEditingController _controller;
  String _currentInput = '';
  bool _isSearching = false;
  int puan=50;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _currentInput = _controller.text.trim();
      });
    });
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    await yeniulkesec();
    await bayrakoyunkurallari();
  }
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }
  Future<bool> _fileExists(String path) async {
    try {
      return File(path).existsSync();
    } catch (e) {
      print('dosya bulunamadi');
      return false;
    }
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
        Dogru();
        setState(() {
          toplampuan+=puan;
          writeToFile();
        });
      } else {
        puan-=10;
        if(puan<20)
          puan=20;
        Yanlis();
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
      Yenitur();
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
                              // İnternet hatası durumunda, kullanıcıya hata mesajı göster
                              return Center(
                                child: Text(
                                  'İnternet Hatası',
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
                    child: Text('Tahmini Kontrol Et'),
                  ),
                  ElevatedButton(
                    onPressed: _pasButtonPressed,
                    child: Text('Pas'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Şuanda Yazılan: $_currentInput'),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _toggleSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Butonun arka plan rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          textStyle: TextStyle(fontSize: 16), // Buton metni stilini ayarlayın
                        ),
                        child: Text(_isSearching ? 'Arama Kutusunu Gizle' : 'Arama Kutusunu Göster'),
                      ),
                      SizedBox(height: 20),
                      if (_isSearching)
                        SearchField<Ulkeler>(
                          suggestions: ulke
                              .where((e) => e.isim.toLowerCase().contains(_currentInput.toLowerCase()))
                              .map(
                                (e) => SearchFieldListItem<Ulkeler>(
                              e.isim,
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
                                        e.isim,
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
                              _currentInput = value.searchKey; // Güncellenmiş metni ayarla
                            });
                          },
                        ),
                    ],
                  ),
                ),
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
