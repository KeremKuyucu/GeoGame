import 'package:geogame/util.dart';

class BaskentOyun extends StatefulWidget {
  @override
  _BaskentOyunState createState() => _BaskentOyunState();
}

class _BaskentOyunState extends State<BaskentOyun> {
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
    baskentoyunkurallari();
  }

  Future<void> baskentoyunkurallari() async {
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
        _controller.clear();
        yeniulkesec();
        baskentdogru++;
        baskentpuan += puan;
        writeToFile();
        puan = 50;
        Dogru();
      } else {
        puan -= 10;
        Yanlis();
        if (puan < 20) puan = 20;
        _controller.clear();
        baskentyanlis++;
        writeToFile();
        butontiklama[i] = false;
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
    setState(() {
      yeniulkesec();
      _controller.clear();
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
                                  CircleAvatar(
                                      backgroundImage: NetworkImage(e.url)),
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
