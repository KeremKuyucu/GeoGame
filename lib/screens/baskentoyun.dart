import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:searchfield/searchfield.dart';

class BaskentOyun extends StatefulWidget {
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
    await baskentoyunkurallari(context);
  }
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
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
            content: Text(Yazi.get('yanliscevap')),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(Yazi.get('yazilan') +_currentInput),
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
                              _currentInput = value.searchKey;
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
                        Text(Yazi.get('sikgizle')),
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
