import 'package:flutter/material.dart';
import 'package:geogame/ulke.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:geogame/screens/baskentoyun.dart';
import 'package:geogame/screens/bayrakoyun.dart';
import 'package:geogame/screens/mesafeoyun.dart';
import 'package:geogame/screens/settings_page.dart';

class GeoGameLobi extends StatefulWidget {
  @override
  _GeoGameLobiState createState() => _GeoGameLobiState();
}
class _GeoGameLobiState extends State<GeoGameLobi> {
  int _selectedOption = 0;
  final List<String> _options = [
    '1. Baskentden Ülke Bilme Oyunu',
    '2. Bayraktan Ülke Bilme Oyunu',
    '3. Mesafeden Ülke Bilme Oyunu',
    '4. Ayarlar',
  ];

  @override
  void initState() {
    super.initState();
    readFromFile();
  }
  Future<void> readFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/ulkekurallari.txt';
    final file = File(filePath);

    if (await file.exists()) {
      // Dosyadan veriyi oku
      final contents = await file.readAsString();

      // Her satırı parçala ve boolean değerlere dönüştür
      final lines = contents.split('\n');
      amerikakitasi = lines[0] == 'true';
      asyakitasi = lines[1] == 'true';
      afrikakitasi = lines[2] == 'true';
      avrupakitasi = lines[3] == 'true';
      okyanusyakitasi = lines[4] == 'true';
      antartikakitasi = lines[5] == 'true';
      bmuyeligi = lines[6] == 'true';
    } else {
      print('Dosya bulunamadı.');
    }
  }
  Future<void> writeToFile() async {
   final directory = await getApplicationDocumentsDirectory();
   final filePath = '${directory.path}/ulkekurallari.txt';
   final file = File(filePath);
   final data = [
     amerikakitasi.toString(),
     asyakitasi.toString(),
     afrikakitasi.toString(),
     avrupakitasi.toString(),
     okyanusyakitasi.toString(),
     antartikakitasi.toString(),
     bmuyeligi.toString(),
   ].join('\n');
   await file.writeAsString(data);
 }
  void _selectOption(int index) async {
   setState(() {
     _selectedOption = index;
   });
   if (index == 0) {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => BaskentOyun(kalici: kalici, gecici: gecici)),
     );
   } else if (index == 1) {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => BayrakOyun(kalici: kalici, gecici: gecici)),
     );
   } else if (index == 2) {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => MesafeOyun(kalici: kalici, gecici: gecici)),
     );
   }else if (index == 3) {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => SettingsPage()),
     );
   }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GeoGame',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedOption = 0;
              });
            },
            icon: Image.network(
              'https://cdn.glitch.global/a083c0fd-0f15-4d63-ba91-bc41d6cf0c4e/images.png?v=1724367094176',
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
            color: Colors.red,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Seçeneklerden Birini Seçin:',
              style: TextStyle(fontSize: 24,color: Colors.blue),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: _selectedOption == index ? Colors.blueAccent : Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _selectOption(index),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _options[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: EdgeInsets.all(16.0),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Bayrak Oyununda Bayraklar Yüklenmiyorsa İnternet Bağlantınızı Kontrol Edin. Ayarlardan Şarkı Açabilirsiniz(İnternet Gerekli)',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
