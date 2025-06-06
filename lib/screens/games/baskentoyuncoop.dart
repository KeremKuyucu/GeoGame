import 'package:GeoGame/util.dart';

class BaskentOyunCoop extends StatefulWidget {
  @override
  _BaskentOyunCoopState createState() => _BaskentOyunCoopState();
}

class _BaskentOyunCoopState extends State<BaskentOyunCoop> {
  bool isPortraitUp = true;
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
    await baskentoyunkurallari();
  }
  Future<void> baskentoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kurallar')),
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
        ekrancevir();
        baskentdogru++;
        baskentpuan += puan;
        writeToFile();
        postUlkeLog(
            '{\n"name": "$name",\n'
                '"uid": "$uid",\n'
                '"oyunmodu": "baskent coop",\n'
                '"mesaj": "Cevap Doğru",\n'
                '"dogrucevap": "${kalici.isim}",\n'
                '"verilencevap": "$ulke",\n'
                '"yesil": "${butonAnahtarlar[0]}",\n'
                '"sari": "${butonAnahtarlar[1]}",\n'
                '"mavi": "${butonAnahtarlar[2]}",\n'
                '"kirmizi": "${butonAnahtarlar[3]}"\n}');
        puan = 50;
      } else {
        String ulke = _controller.text.trim();
        puan -= 10;
        if (puan < 20) puan = 20;
        _controller.clear();
        baskentyanlis++;
        writeToFile();
        butontiklama[i]=false;
        postUlkeLog(
            '{\n"name": "$name",\n'
                '"uid": "$uid",\n'
                '"oyunmodu": "baskent",\n'
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
  void ekrancevir() {
    // Yön değiştirmek için UI'dan sonra yapılacak işlemleri belirleyelim.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPortraitUp) {
        // Eğer mevcut yön portre üst ise, portre alt yap
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown]);
      } else {
        // Eğer mevcut yön portre alt ise, portre üst yap
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }

      // Yönü tersine çevir
      isPortraitUp = !isPortraitUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('baskentbaslik')),
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
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  Yazi.get('baskenticerik') + kalici.baskent,
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: null,
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
                if(!yazmamodu)
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
                              CircleAvatar(backgroundImage: NetworkImage(e.url)),
                              const SizedBox(width: 10),
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
      ),
    );
  }
}
