import 'package:GeoGame/util.dart';

class BayrakOyun extends StatefulWidget {
  @override
  _BayrakOyunState createState() => _BayrakOyunState();
}

class _BayrakOyunState extends State<BayrakOyun> {

  late TextEditingController _controller;
  String _currentInput = '';
  int puan = 50;
  @override
  void initState() {
    super.initState();
    _initializeGame();

  }

  Future<void> _initializeGame() async {
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _currentInput = _controller.text.trim();
      });
    });
    await readFromFile((update) => setState(update));
    yeniulkesec();
    await bayrakoyunkurallari();
  }
  Future<void> bayrakoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kurallar')),
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
              child: Text(Yazi.get('tamam')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _checkAnswer(int i) {
    setState(() {
      if (kalici.ks(kelimeDuzelt(_controller.text.trim()))) {
        String ulke = kelimeDuzelt(_controller.text.trim());
        _controller.clear();
        _currentInput = '';
        yeniulkesec();
        Dogru();
        bayrakdogru++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Yazi.get('dogrucevap')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        postUlkeLog(
            '{\n"name": "$name",\n'
                '"oyunmodu": "bayrak",\n'
                '"mesaj": "Cevap Doğru",\n'
                '"dogrucevap": "${kalici.isim}",\n'
                '"verilencevap": "$ulke",\n'
                '"yesil": "${butonAnahtarlar[0]}",\n'
                '"sari": "${butonAnahtarlar[1]}",\n'
                '"mavi": "${butonAnahtarlar[2]}",\n'
                '"kirmizi": "${butonAnahtarlar[3]}"\n}');
        setState(() {
          bayrakpuan += puan;
          writeToFile();
        });
        puan = 50;
      } else {
        String ulke = kelimeDuzelt(_controller.text.trim());
        puan -= 10;
        if (puan < 20) puan = 20;
        Yanlis();
        butontiklama[i]=false;
        _controller.clear();
        _currentInput='';
        bayrakyanlis++;
        writeToFile();
        postUlkeLog(
            '{\n"name": "$name",\n'
                '"oyunmodu": "bayrak",\n'
                '"Mesaj": "Cevap Yanlış",\n'
                '"dogrucevap": "${kalici.isim}",\n'
                '"verilencevap": "$ulke",\n'
                '"yesil": "${butonAnahtarlar[0]}",\n'
                '"sari": "${butonAnahtarlar[1]}",\n'
                '"mavi": "${butonAnahtarlar[2]}",\n'
                '"kirmizi": "${butonAnahtarlar[3]}"\n}');
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
    String ulke = kelimeDuzelt(_controller.text.trim());
    postUlkeLog(
        '{\n"name": "$name",\n'
            '"oyunmodu": "bayrak",\n'
            '"Mesaj": "Pas Geçildi",\n'
            '"dogrucevap": "${kalici.isim}",\n'
            '"verilencevap": "$ulke",\n'
            '"yesil": "${butonAnahtarlar[0]}",\n'
            '"sari": "${butonAnahtarlar[1]}",\n'
            '"mavi": "${butonAnahtarlar[2]}",\n'
            '"kirmizi": "${butonAnahtarlar[3]}"\n}');
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
        title: Text(Yazi.get('bayrakbaslik')),
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
      drawer: DrawerWidget(),
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
                                  'İnternet Error',
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
              ), // bayrak
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: _pasButtonPressed,
                        child: Text(
                          Yazi.get('pas'),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
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
                                onPressed: butontiklama[i] ? () {
                                  _controller.text = butonAnahtarlar[i];
                                  _checkAnswer(i);
                                } : null,
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
                                onPressed: butontiklama[i] ? () {
                                  _controller.text = butonAnahtarlar[i];
                                  _checkAnswer(i);
                                } : null,
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
              if (!yazmamodu)
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
                          setState(() {
                            _controller.text = value.searchKey;
                            _currentInput = value.searchKey;
                            _checkAnswer(5);
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
