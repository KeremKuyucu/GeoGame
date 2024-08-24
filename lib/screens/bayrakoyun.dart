import 'package:flutter/material.dart';
import 'package:geogame/ulke.dart';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
Future<void> _playSoundEffect(String url) async {
  try {
    final soundPlayer = AudioPlayer();
    await soundPlayer.play(UrlSource(url));
    soundPlayer.setVolume(1);
    soundPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        soundPlayer.dispose();
      }
    });
  } catch (e) {
    print('Ses çalma hatası: $e');
  }
}
final String dogru = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/dogru.ogg?v=1724449062669';
final String yanlis = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yanlis.ogg?v=1724449063037';
final String yenitur = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yenitur.ogg?v=1724449063453';
class BayrakOyun extends StatefulWidget {
  final Ulkeler kalici;
  final Ulkeler gecici;

  BayrakOyun({required this.kalici, required this.gecici});

  @override
  _BayrakOyunState createState() => _BayrakOyunState();
}

class _BayrakOyunState extends State<BayrakOyun> {
  int randomSayi = 0;
  final random = Random();
  late TextEditingController _controller;
  late Future<ImageProvider> _imageProvider;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    bool gecicibilgi = false;
    do {
      randomSayi = random.nextInt(ulke.length);
      for (var ulke in ulke) {
        if (!ulke.bilgi &&
            !(ulke.kita == "Americas" && !amerikakitasi) &&
            !(ulke.kita == "Asia" && !asyakitasi) &&
            !(ulke.kita == "Africa" && !afrikakitasi) &&
            !(ulke.kita == "Europe" && !avrupakitasi) &&
            !(ulke.kita == "Oceania" && !okyanusyakitasi) &&
            !(ulke.kita == "Antarctic" && !antartikakitasi) &&
            !(ulke.bm && !bmuyeligi)) {
          gecicibilgi = true;
          break;
        }
      }
      if (!gecicibilgi) {
        for (var ulke in ulke) {
          ulke.bilgi = false;
        }
      }
    } while (ulke[randomSayi].bilgi ||
        (!amerikakitasi && ulke[randomSayi].kita == "Americas") ||
        (!asyakitasi && ulke[randomSayi].kita == "Asia") ||
        (!afrikakitasi && ulke[randomSayi].kita == "Africa") ||
        (!avrupakitasi && ulke[randomSayi].kita == "Europe") ||
        (!okyanusyakitasi && ulke[randomSayi].kita == "Oceania") ||
        (!antartikakitasi && ulke[randomSayi].kita == "Antarctic") ||
        (!bmuyeligi && !ulke[randomSayi].bm) ||
        (ulke[randomSayi].bilgi == true));
    kalici = ulke[randomSayi];
    ulke[randomSayi].bilgi = true;
    _playSoundEffect(yenitur);
  }
  Future<bool> _fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  void _checkAnswer() {
    setState(() {
      if (kalici.ks(kelimeDuzelt(_controller.text.trim().toLowerCase()))) {
        _controller.clear(); // Giriş alanını temizle
        bool gecicibilgi = false;
        do {
          randomSayi = random.nextInt(ulke.length);
          for (var ulke in ulke) {
            if (!ulke.bilgi &&
                !(ulke.kita == "Americas" && !amerikakitasi) &&
                !(ulke.kita == "Asia" && !asyakitasi) &&
                !(ulke.kita == "Africa" && !afrikakitasi) &&
                !(ulke.kita == "Europe" && !avrupakitasi) &&
                !(ulke.kita == "Oceania" && !okyanusyakitasi) &&
                !(ulke.kita == "Antarctic" && !antartikakitasi) &&
                !(ulke.bm && !bmuyeligi)) {
              gecicibilgi = true;
              break;
            }
          }
          if (!gecicibilgi) {
            for (var ulke in ulke) {
              ulke.bilgi = false;
            }
          }
        } while (ulke[randomSayi].bilgi ||
            (!amerikakitasi && ulke[randomSayi].kita == "Americas") ||
            (!asyakitasi && ulke[randomSayi].kita == "Asia") ||
            (!afrikakitasi && ulke[randomSayi].kita == "Africa") ||
            (!avrupakitasi && ulke[randomSayi].kita == "Europe") ||
            (!okyanusyakitasi && ulke[randomSayi].kita == "Oceania") ||
            (!antartikakitasi && ulke[randomSayi].kita == "Antarctic") ||
            (!bmuyeligi && !ulke[randomSayi].bm) ||
            (ulke[randomSayi].bilgi == true));
        kalici = ulke[randomSayi];
        ulke[randomSayi].bilgi = true;
        _playSoundEffect(dogru);
      } else {
        _playSoundEffect(yanlis);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Geçilen Ülke: ${kalici.isim}'),
        backgroundColor: Colors.yellow,
        duration: Duration(seconds: 2),
      ),
    );
    setState(()  {
      bool gecicibilgi = false;
      do {
        randomSayi = random.nextInt(ulke.length);
        for (var ulke in ulke) {
          if (!ulke.bilgi &&
              !(ulke.kita == "Americas" && !amerikakitasi) &&
              !(ulke.kita == "Asia" && !asyakitasi) &&
              !(ulke.kita == "Africa" && !afrikakitasi) &&
              !(ulke.kita == "Europe" && !avrupakitasi) &&
              !(ulke.kita == "Oceania" && !okyanusyakitasi) &&
              !(ulke.kita == "Antarctic" && !antartikakitasi) &&
              !(ulke.bm && !bmuyeligi)) {
            gecicibilgi = true;
            break;
          }
        }
        if (!gecicibilgi) {
          for (var ulke in ulke) {
            ulke.bilgi = false;
          }
        }
      } while (ulke[randomSayi].bilgi ||
          (!amerikakitasi && ulke[randomSayi].kita == "Americas") ||
          (!asyakitasi && ulke[randomSayi].kita == "Asia") ||
          (!afrikakitasi && ulke[randomSayi].kita == "Africa") ||
          (!avrupakitasi && ulke[randomSayi].kita == "Europe") ||
          (!okyanusyakitasi && ulke[randomSayi].kita == "Oceania") ||
          (!antartikakitasi && ulke[randomSayi].kita == "Antarctic") ||
          (!bmuyeligi && !ulke[randomSayi].bm) ||
          (ulke[randomSayi].bilgi == true));
      kalici = ulke[randomSayi];
      ulke[randomSayi].bilgi = true;
      _playSoundEffect(yenitur);
      _controller.clear(); // Giriş alanını temizle
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
              Text(
                'Tahmin Edilecek Ülke: ',
                //${kalici.isim} lazım olursa tekrar yazarsın
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 320, // Maksimum genişlik
                child: FutureBuilder<bool>(
                  future: _fileExists(kalici.bayrak), // Dosyanın var olup olmadığını kontrol et
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.data!) {
                      // Dosya bulunamadığında
                      return Image.network(
                        kalici.url,
                        fit: BoxFit.contain, // Resmi orantılı olarak kutuya sığdırır
                        width: 320, // Genişliği sabitler
                      );
                    } else {
                      // Dosya bulunduğunda
                      return Image.asset(
                        kalici.bayrak,
                        fit: BoxFit.contain, // Resmi orantılı olarak kutuya sığdırır
                        width: 320, // Genişliği sabitler
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Ekranın %80'i kadar genişlik
                  child: TextField(
                    controller: _controller,
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
