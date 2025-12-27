import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'dart:math';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/models/countries.dart';
import 'package:geogame/models/drawer_widget.dart';

import 'package:geogame/widgets/custom_notification.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/game_log_service.dart';

import 'package:geogame/screens/mainscreen/main_screen.dart';

class MesafeOyun extends StatefulWidget {
  @override
  _MesafeOyunState createState() => _MesafeOyunState();
}

class _MesafeOyunState extends State<MesafeOyun> {
  String message = '';
  late TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    AppState.session.reset(
      startScore: 300,
      minScore: 100,
    );
    yeniulkesec();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mesafeoyunkurallari();
    });
  }

  Future<void> mesafeoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Localization.get('kurallar')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Localization.get('kural1')),
                Text(Localization.get('mesafekural2')),
                Text(Localization.get('mesafekural3')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Localization.get('tamam')),
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
    String girilenMetin = _controller.text.trim();

    if (girilenMetin.isEmpty) return;

    setState(() {
      try {
        gecici = tumUlkeler.firstWhere(
              (u) => u.ks(girilenMetin),
        );
      } catch (e) {
        debugPrint("Böyle bir ülke bulunamadı: $girilenMetin");
        return;
      }

      message += Localization.get('tahminmetin') +
          (AppState.settings.isEnglish ? gecici.enisim : gecici.isim) +
          "    ";

      message += Localization.get('mesafe') +
          mesafeHesapla(
              gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam)
              .toString() +
          " Km   ";

      message += Localization.get('yon') +
          pusula(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam) +
          "\n";

      if (kalici.ks(girilenMetin)) {
        _controller.clear();
        message = '';

        AppState.session.submitCorrect();
        GameLogService.saveToStorage("distance");
        yeniulkesec();

      } else {
        AppState.session.submitWrong();
        _controller.clear();
        AppState.stats.distanceWrongCount++;

      }
    });
  }

  void _pasButtonPressed() {
    AppState.session.submitPass();
    String pasulke = (AppState.settings.isEnglish ? kalici.enisim : kalici.isim);
    showDialog(
      context: context,
      builder: (context) {
        return CustomNotification(baslik: Localization.get('pascevap'), metin: pasulke);
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
    List<String> yonler = AppState.settings.isEnglish ? yonlerEN : yonlerTR;
    return yonler[((brng + 22.5) / 45.0).floor() % 8];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.get('mesafebaslik')),
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
              GameLogService.syncPendingLogs();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
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
                          Localization.get('pas'),
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
                          Localization.get('tahmintemizle'),
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
                  suggestions: tumUlkeler
                      .map(
                        (e) => SearchFieldListItem<Ulkeler>(
                          AppState.settings.isEnglish ? e.enisim : e.isim,
                          item: e,
                          child: Row(
                            children: [
                              CircleAvatar(
                                  backgroundImage: NetworkImage(e.url)),
                              const SizedBox(width: 10),
                              Text(AppState.settings.isEnglish ? e.enisim : e.isim),
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
