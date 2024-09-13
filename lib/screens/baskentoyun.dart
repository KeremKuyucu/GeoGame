import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:searchfield/searchfield.dart';

class BaskentOyun extends StatefulWidget {
  BaskentOyun();

  @override
  _BaskentOyunState createState() => _BaskentOyunState();
}

class _BaskentOyunState extends State<BaskentOyun> {
  late TextEditingController _controller;
  String _currentInput = '';
  bool _isSearching = false;
  int puan=50;
  String suggestedText = '';
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
    await baskentoyunkurallari();
  }
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }
  Future<void> baskentoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kurallar'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Baskent Bilme Oyunu'),
                Text('Baskent Bilme Oyununa hos geldiniz.\nAmaciniz 250 ulkeden rastgele secilen bir ulkenin baskentini bilmek.'),
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
        _controller.clear();
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
        title: Text('Baskent Oyun'),
      ),
      body: Center(
        child: SingleChildScrollView(
         child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Tahmin Edilecek Ülkenin\n Başkenti: ${kalici.baskent}',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
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
               padding: const EdgeInsets.all(16.0), // Padding'i artırdım
               child: Container(
                 width: MediaQuery.of(context).size.width * 0.8,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start, // Sol hizalamayı ekledim
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween, // Daha iyi yerleşim için
                       children: [
                         Text(
                           'Şuanda Yazılan: $_currentInput',
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Daha belirgin metin
                         ),
                       ],
                     ),
                     SizedBox(height: 16), // Araya boşluk ekledim
                     ElevatedButton(
                       onPressed: _toggleSearch,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blueAccent, // Butonun arka plan rengi
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                         padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28), // Daha geniş buton
                         textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Buton metni stilini ayarladım
                       ),
                       child: Text(_isSearching ? 'Arama Kutusunu Gizle' : 'Arama Kutusunu Göster'),
                     ),
                     SizedBox(height: 20),
                     if (_isSearching)
                       SearchField<Ulkeler>(
                         suggestions: ulke
                             .where((e) =>
                         e.isim.toLowerCase().contains(_currentInput.toLowerCase()) &&
                             (!amerikakitasi && e.kita == "Americas" ||
                                 !asyakitasi && e.kita == "Asia" ||
                                 !afrikakitasi && e.kita == "Africa" ||
                                 !avrupakitasi && e.kita == "Europe" ||
                                 !okyanusyakitasi && e.kita == "Oceania" ||
                                 !antartikakitasi && e.kita == "Antarctic" ||
                                 !bmuyeligi && !e.bm))
                             .map(
                               (e) => SearchFieldListItem<Ulkeler>(
                             e.isim,
                             item: e,
                             child: Padding(
                               padding: const EdgeInsets.all(12.0), // Padding artırıldı
                               child: Row(
                                 children: [
                                   CircleAvatar(
                                     backgroundImage: NetworkImage(e.url),
                                     radius: 22, // Çemberin büyüklüğü artırıldı
                                   ),
                                   SizedBox(width: 12), // Boşluk artırıldı
                                   Expanded(
                                     child: Text(
                                       e.isim,
                                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Yazı stili güncellendi
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
      ),
    );
  }
}
