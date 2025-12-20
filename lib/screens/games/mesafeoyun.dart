import 'package:geogame/util.dart';

class MesafeOyun extends StatefulWidget {
  @override
  _MesafeOyunState createState() => _MesafeOyunState();
}

class _MesafeOyunState extends State<MesafeOyun> {
  String message = '';
  late TextEditingController _controller = TextEditingController();
  int puan = 100;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    yeniulkesec();
    await mesafeoyunkurallari();
  }

  Future<void> mesafeoyunkurallari() async {
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
                Text(Yazi.get('mesafekural2')),
                Text(Yazi.get('mesafekural3')),
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

  void _checkAnswer() {
    setState(() {
      for (int a = 0; a < 250; a++) {
        if (ulke[a].ks(_controller.text.trim())) {
          gecici = ulke[a];
          break;
        }
      }
      message += Yazi.get('tahminmetin') +
          (isEnglish ? gecici.enisim : gecici.isim) +
          "    ";
      message += Yazi.get('mesafe') +
          mesafeHesapla(
                  gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam)
              .toString() +
          " Km   ";
      message += Yazi.get('yon') +
          pusula(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam) +
          "\n";
      if (kalici.ks(_controller.text.trim())) {
        _controller.clear();
        message = '';
        yeniulkesec();
        mesafedogru++;
        mesafepuan += puan;
        writeToFile();
        puan = 300;
        Dogru();
      } else {
        puan -= 10;
        Yanlis();
        if (puan < 100) puan = 100;
        _controller.clear();
        mesafeyanlis++;
        writeToFile();
      }
    });
  }

  void _pasButtonPressed() {
    puan = 300;
    Yanlis();
    String pasulke = (isEnglish ? kalici.enisim : kalici.isim);
    showDialog(
      context: context,
      builder: (context) {
        return CustomNotification(baslik: Yazi.get('pascevap'), metin: pasulke);
      },
    );
    setState(() {
      message = '';
      yeniulkesec();
      _controller.clear();
    });
  }

  double mesafeHesapla(double latitude1, double longitude1, double latitude2,
      double longitude2) {
    const double PI = 3.14159265358979323846264338327950288;
    double theta = longitude1 - longitude2;
    double distance = acos(
            sin(latitude1 * PI / 180.0) * sin(latitude2 * PI / 180.0) +
                cos(latitude1 * PI / 180.0) *
                    cos(latitude2 * PI / 180.0) *
                    cos(theta * PI / 180.0)) *
        180.0 /
        PI;
    distance *= 60 * 1.1515 * 1.609344; // Miles to kilometers conversion
    return distance.roundToDouble();
  }

  String pusula(double lat1, double lon1, double lat2, double lon2) {
    const double PI = 3.14159265358979323846264338327950288;
    lat1 *= PI / 180.0;
    lon1 *= PI / 180.0;
    lat2 *= PI / 180.0;
    lon2 *= PI / 180.0;
    double brng = atan2(sin(lon2 - lon1) * cos(lat2),
            cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1)) *
        180 /
        PI;
    brng = (brng + 360) % 360;

    const List<String> yonlerTR = [
      "Kuzey",
      "Kuzeydoğu",
      "Doğu",
      "Güneydoğu",
      "Güney",
      "Güneybatı",
      "Batı",
      "Kuzeybatı"
    ];
    const List<String> yonlerEN = [
      "North",
      "Northeast",
      "East",
      "Southeast",
      "South",
      "Southwest",
      "West",
      "Northwest"
    ];
    List<String> yonler = isEnglish ? yonlerEN : yonlerTR;
    return yonler[((brng + 22.5) / 45.0).floor() % 8];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('mesafebaslik')),
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
              Text(
                message,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Butonlar arasında eşit boşluk bırakır
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            message = '';
                          });
                        },
                        child: Text(
                          Yazi.get('tahmintemizle'),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
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
                        _checkAnswer();
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
