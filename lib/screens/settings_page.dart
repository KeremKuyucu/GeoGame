import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:GeoGame/ulke.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    playSoundEffect(yenitur);
    _audioPlayer = AudioPlayer();
    readFromFile((update) => setState(update));
    if(false == (amerikakitasi || asyakitasi || afrikakitasi || avrupakitasi || okyanusyakitasi || antartikakitasi)){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMyDialog();
      });
    }
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Hiçbir kıta aktif değil.'),
                Text('Lütfen en az bir kıta aktif edin.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleBackgroundMusic(bool play) async {
    final url = 'https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkafon.mp3?v=1725557913852';
    if (play) {
      try {
        await _audioPlayer.play(UrlSource(url));
        _audioPlayer.setVolume(1);
        setState(() {
          backgroundMusicPlaying = true;
        });
      } catch (e) {
        print('Ses çalma hatası: $e');
      }
    } else {
      if (backgroundMusicPlaying) {
        await _audioPlayer.stop();
        setState(() {
          backgroundMusicPlaying = false;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildSwitch('Amerika Kıtasında Olan Ülkeler', amerikakitasi, (value) {
                setState(() {
                  amerikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch('Asya Kıtasında Olan Ülkeler', asyakitasi, (value) {
                setState(() {
                  asyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch('Afrika Kıtasında Olan Ülkeler', afrikakitasi, (value) {
                setState(() {
                  afrikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch('Avrupa Kıtasında Olan Ülkeler', avrupakitasi, (value) {
                setState(() {
                  avrupakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch('Okyanusya Kıtasında Olan Ülkeler', okyanusyakitasi, (value) {
                setState(() {
                  okyanusyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch('Antartika Kıtasında Olan Ülkeler', antartikakitasi, (value) {
                setState(() {
                  antartikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch('BM Üyeliği Olmayan Ülkeler', bmuyeligi, (value) {
                setState(() {
                  bmuyeligi = value;
                  writeToFile();
                });
              }),
              buildSwitch('Şıklı Bilme Modu', yazmamodu, (value) {
                setState(() {
                  yazmamodu = value;
                  writeToFile();
                });
              }),
              buildSwitch('Arka Fon Şarkı', backgroundMusicPlaying, (value) {
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
