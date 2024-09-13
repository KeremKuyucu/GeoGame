import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:searchfield/searchfield.dart';

class MesafeOyun extends StatefulWidget {
  MesafeOyun();
  @override
  _MesafeOyunState createState() => _MesafeOyunState();
}

class _MesafeOyunState extends State<MesafeOyun> {
  String message='';
  late TextEditingController _controller;
  String _currentInput = '';
  bool _isSearching = false;
  int puan=100;
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
    await mesafeoyunkurallari();
  }
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }
  Future<void> mesafeoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kurallar'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Mesafeden Ulke Bilme Oyunu'),
                Text('Mesafeden ulke bilme oyununa hos geldiniz.\nAmaciniz, 250 ülkeden rastgele secilen bir ulkeyi bilmek.\nMesafeler +-100 Km fark olabilir.\nKonum olarak ülkelerin tam ortalari baz alinmistir.'),
                Text('Puan Sistemi: Her turda puaniniz 100 den baslar her yanlis tahminde 10 puan azalir.\n8 Tahminden sonra kazanilan puan 20\'e sabitlenir tur bitince tekrar 100\'den baslar.'),
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
      for (int a=0;a<250;a++){
        if(ulke[a].ks(kelimeDuzelt(_controller.text.trim()))){
          gecici= ulke[a];
          break;
        }
      }
      message += "Tahmin: " + gecici.isim + "    ";
      message += "Mesafe: " + mesafeHesapla(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam).toString() + " kilometre   ";
      message += "Yön: " + pusula(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam) + "";
      if (kalici.ks(kelimeDuzelt(_controller.text.trim()))) {
        _controller.clear();
        message='';
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
        title: Text('Mesafe Oyun'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                message,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Butonlar arasında eşit boşluk bırakır
                children: [
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    child: Text('Tahmin Gir'),
                  ),
                  ElevatedButton(
                    onPressed: _pasButtonPressed,
                    child: Text('Pas'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        message = '';
                      });
                    },
                    child: Text('Tahminleri Temizle'),
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
            ],
          ),
        ),
      ),
    );
  }
}
