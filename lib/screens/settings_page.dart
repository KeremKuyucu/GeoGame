import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
Future<void> _playSoundEffect(String url) async {
  try {
    final soundPlayer = AudioPlayer();
    await soundPlayer.play(UrlSource(url));
    soundPlayer.setVolume(1);
    soundPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        soundPlayer.dispose();
      }
    });
  } catch (e) {
    print('Ses çalma hatası: $e');
  }
}
final String dogru = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/dogru.ogg?v=1724449062669';
final String yanlis = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yanlis.ogg?v=1724449063037';
final String yenitur = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yenitur.ogg?v=1724449063453';
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final random = Random();
  late final AudioPlayer _audioPlayer;
  bool _backgroundMusicPlaying = false;
  bool amerikakitasi = false;
  bool asyakitasi = false;
  bool afrikakitasi = false;
  bool avrupakitasi = false;
  bool okyanusyakitasi = false;
  bool antartikakitasi = false;
  bool bmuyeligi = false;

  @override
  void initState() {
    super.initState();
    _playSoundEffect(yenitur);
    _audioPlayer = AudioPlayer();
    readFromFile();
  }

  Future<void> readFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/ulkekurallari.txt';
    final file = File(filePath);

    if (await file.exists()) {
      final contents = await file.readAsString();
      final lines = contents.split('\n');

      if (lines.length >= 7) { // Dosyada yeterli satır olduğundan emin olun
        setState(() {
          amerikakitasi = lines[0] == 'true';
          asyakitasi = lines[1] == 'true';
          afrikakitasi = lines[2] == 'true';
          avrupakitasi = lines[3] == 'true';
          okyanusyakitasi = lines[4] == 'true';
          antartikakitasi = lines[5] == 'true';
          bmuyeligi = lines[6] == 'true';
          // Dosyadan okunan müzik durumu
          _backgroundMusicPlaying = lines[7] == 'true';
        });
      }
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
      _backgroundMusicPlaying.toString(), // Müzik durumunu da dosyaya yaz
    ].join('\n');
    await file.writeAsString(data);
  }
  void _toggleBackgroundMusic(bool play) async {
    final url = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkafon.mp3?v=1724447133191';

    if (play) {
      try {
        await _audioPlayer.play(UrlSource(url));
        _audioPlayer.setVolume(1);
        setState(() {
          _backgroundMusicPlaying = true;
        });
      } catch (e) {
        print('Ses çalma hatası: $e');
      }
    } else {
      if (_backgroundMusicPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _backgroundMusicPlaying = false;
        });
      }
    }
    await writeToFile(); // Güncellenmiş durumu dosyaya yaz
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildSwitch('Amerika Kıtasında Olan Ülkeler', amerikakitasi, (value) {
              setState(() {
                amerikakitasi = value;
                writeToFile(); // Güncellenmiş durumu dosyaya yaz
              });
            }),
            buildSwitch('Asya Kıtasında Olan Ülkeler', asyakitasi, (value) {
              setState(() {
                asyakitasi = value;
                writeToFile(); // Güncellenmiş durumu dosyaya yaz
              });
            }),
            buildSwitch('Afrika Kıtasında Olan Ülkeler', afrikakitasi, (value) {
              setState(() {
                afrikakitasi = value;
                writeToFile(); // Güncellenmiş durumu dosyaya yaz
              });
            }),
            buildSwitch('Avrupa Kıtasında Olan Ülkeler', avrupakitasi, (value) {
              setState(() {
                avrupakitasi = value;
                writeToFile(); // Güncellenmiş durumu dosyaya yaz
              });
            }),
            buildSwitch('Okyanusya Kıtasında Olan Ülkeler', okyanusyakitasi, (value) {
              setState(() {
                okyanusyakitasi = value;
                writeToFile(); // Güncellenmiş durumu dosyaya yaz
              });
            }),
            buildSwitch('Antarktika Kıtasında Olan Ülkeler', antartikakitasi, (value) {
              setState(() {
                antartikakitasi = value;
                writeToFile(); // Güncellenmiş durumu dosyaya yaz
              });
            }),
            buildSwitch('BM Üyeliği Olmayan Ülkeler', bmuyeligi, (value) {
              setState(() {
                bmuyeligi = value;
                writeToFile(); // Güncellenmiş durumu dosyaya yaz
              });
            }),
            buildSwitch('Arka Fon Şarkı', _backgroundMusicPlaying, (value) {
              _toggleBackgroundMusic(value);
            }),
            Card(
              margin: EdgeInsets.all(16.0),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Text(
                      'Web Sürümünde Ayarları Kayıt Etme Özelliği Çalışmamakta Eğer Ülke Filtrelemek İsterseniz Mobil veya Windows Sürümünü Yükleyin. Şarkı Çalmıyorsa Şarkıyı Aç Kapat Yapabilirsiniz.',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSwitch(String title, bool currentValue, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16.0)),
          Switch(
            value: currentValue,
            onChanged: onChanged,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
