import 'package:GeoGame/util.dart';

class BayrakOyun extends StatefulWidget {
  @override
  _BayrakOyunState createState() => _BayrakOyunState();
}

class _BayrakOyunState extends State<BayrakOyun> {
  late TextEditingController _controller = TextEditingController();
  int puan = 50;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    yeniulkesec();
    await bayrakoyunkurallari();
  }

  Future<void> bayrakoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kurallar')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('kural1')),
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
      if (kalici.ks(_controller.text.trim())) {
        String ulke = _controller.text.trim();
        _controller.clear();
        yeniulkesec();
        bayrakdogru++;
        bayrakpuan += puan;
        writeToFile();
        postUlkeLog('{\n"name": "$name",\n'
            '"uid": "$uid",\n'
            '"oyunmodu": "bayrak",\n'
            '"mesaj": "Cevap Doğru",\n'
            '"dogrucevap": "${kalici.isim}",\n'
            '"verilencevap": "$ulke",\n'
            '"yesil": "${butonAnahtarlar[0]}",\n'
            '"sari": "${butonAnahtarlar[1]}",\n'
            '"mavi": "${butonAnahtarlar[2]}",\n'
            '"kirmizi": "${butonAnahtarlar[3]}"\n}');
        puan = 50;
        Dogru();
      } else {
        String ulke = _controller.text.trim();
        puan -= 10;
        Yanlis();
        if (puan < 20) puan = 20;
        butontiklama[i] = false;
        _controller.clear();
        bayrakyanlis++;
        writeToFile();
        postUlkeLog('{\n"name": "$name",\n'
            '"uid": "$uid",\n'
            '"oyunmodu": "bayrak",\n'
            '"mesaj": "Cevap Yanlış",\n'
            '"dogrucevap": "${kalici.isim}",\n'
            '"verilencevap": "$ulke",\n'
            '"yesil": "${butonAnahtarlar[0]}",\n'
            '"sari": "${butonAnahtarlar[1]}",\n'
            '"mavi": "${butonAnahtarlar[2]}",\n'
            '"kirmizi": "${butonAnahtarlar[3]}"\n}');
      }
    });
  }

  void _pasButtonPressed() {
    puan = 50;
    Yanlis();
    String pasulke = (isEnglish ? kalici.enisim : kalici.isim);
    showDialog(
      context: context,
      builder: (context) {
        return CustomNotification(baslik: Yazi.get('pascevap'), metin: pasulke);
      },
    );
    String ulke = _controller.text.trim();
    postUlkeLog('{\n"name": "$name",\n'
        '"uid": "$uid",\n'
        '"oyunmodu": "bayrak",\n'
        '"mesaj": "Pas Geçildi",\n'
        '"dogrucevap": "${kalici.isim}",\n'
        '"verilencevap": "$ulke",\n'
        '"yesil": "${butonAnahtarlar[0]}",\n'
        '"sari": "${butonAnahtarlar[1]}",\n'
        '"mavi": "${butonAnahtarlar[2]}",\n'
        '"kirmizi": "${butonAnahtarlar[3]}"\n}');
    setState(() {
      yeniulkesec();
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
                                onPressed: butontiklama[i]
                                    ? () {
                                        _controller.text = butonAnahtarlar[i];
                                        _checkAnswer(i);
                                      }
                                    : null,
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
                                onPressed: butontiklama[i]
                                    ? () {
                                        _controller.text = butonAnahtarlar[i];
                                        _checkAnswer(i);
                                      }
                                    : null,
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
              if (!yazmamodu)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchField<Ulkeler>(
                    suggestions: ulke
                        .map(
                          (e) => SearchFieldListItem<Ulkeler>(
                            isEnglish ? e.enisim : e.isim,
                            item: e,
                            child: Row(
                              children: [
                                Text(isEnglish ? e.enisim : e.isim),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    controller: _controller,
                    onSuggestionTap: (value) {
                      if (value.item != null) {
                        setState(() {
                          _controller.text = value.searchKey;
                          _checkAnswer(4);
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
