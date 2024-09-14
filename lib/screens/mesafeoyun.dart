import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:searchfield/searchfield.dart';
import 'dart:math';

class MesafeOyun extends StatefulWidget {
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
          title: Text(Yazi.get('mesafekural')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('mesafekural1')),
                Text(Yazi.get('mesafekural2')),
                Text(Yazi.get('mesafekural3')),
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
      for (int a=0;a<250;a++){
        if(ulke[a].ks(kelimeDuzelt(_controller.text.trim()))){
          gecici= ulke[a];
          break;
        }
      }
      message += Yazi.get('mesafetahmin') + gecici.isim + "    ";
      message += Yazi.get('mesafetahmin1') + mesafeHesapla(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam).toString() + " km   ";
      message += Yazi.get('mesafetahmin2') + pusula(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam) + "\n";
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
            content: Text(Yazi.get('mesafetahmin3')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
  void _pasButtonPressed() {
    puan=100;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Yazi.get('gecilenulke')+kalici.isim),
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
  double mesafeHesapla(double latitude1, double longitude1, double latitude2, double longitude2) {
    const double PI = 3.14159265358979323846264338327950288;
    double theta = longitude1 - longitude2;
    double distance = acos(sin(latitude1 * PI / 180.0) * sin(latitude2 * PI / 180.0) +
        cos(latitude1 * PI / 180.0) * cos(latitude2 * PI / 180.0) * cos(theta * PI / 180.0)) * 180.0 / PI;
    distance *= 60 * 1.1515 * 1.609344; // Miles to kilometers conversion
    return distance.roundToDouble();
  }
  String pusula(double lat1, double lon1, double lat2, double lon2) {
    const double PI = 3.14159265358979323846264338327950288;
    lat1 *= PI / 180.0;
    lon1 *= PI / 180.0;
    lat2 *= PI / 180.0;
    lon2 *= PI / 180.0;
    double brng = atan2(sin(lon2 - lon1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1)) * 180 / PI;
    brng = (brng + 360) % 360;

    const List<String> yonlerTR = ["Kuzey", "Kuzeydoğu", "Doğu", "Güneydoğu", "Güney", "Güneybatı", "Batı", "Kuzeybatı"];
    const List<String> yonlerEN = ["North", "Northeast", "East", "Southeast", "South", "Southwest", "West", "Northwest"];
    List<String> yonler = isEnglish ? yonlerEN : yonlerTR;
    return yonler[((brng + 22.5) / 45.0).floor() % 8];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('mesafe')),
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
                    child: Text(Yazi.get('tahmin1')),
                  ),
                  ElevatedButton(
                    onPressed: _pasButtonPressed,
                    child: Text(Yazi.get('pas')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        message = '';
                      });
                    },
                    child: Text(Yazi.get('tahmin2')),
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
                          Text(Yazi.get('yazilan')+_currentInput),
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
                        child: Text(_isSearching ? Yazi.get('aramagizle') : Yazi.get('aramagoster')),
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
