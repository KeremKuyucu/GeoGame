import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';

class MesafeOyun extends StatefulWidget {
  MesafeOyun();
  @override
  _MesafeOyunState createState() => _MesafeOyunState();
}

class _MesafeOyunState extends State<MesafeOyun> {
  String message='';
  late TextEditingController _controller;
  String suggestedText = '';
  int puan=100;
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
    await mesafeoyunkurallari();
  }
  void _updateSuggestedText(String text) {
    setState(() {
      suggestedText = bulunanBenzerUlke(kelimeDuzelt(text), ulke);
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
    setState(() {
      yeniulkesec();
      playSoundEffect(yenitur);
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
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.text = bulunanBenzerUlke(kelimeDuzelt(_controller.text.trim()), ulke);
                  });
                },
                child: Text('Şunu mu Demek İstediniz: $suggestedText'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
