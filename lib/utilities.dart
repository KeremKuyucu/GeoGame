import 'package:geogame/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/app_context.dart';


class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _sebepController = TextEditingController();
    final TextEditingController _messageController = TextEditingController();

    Future<void> sendMessage(String sebep, String message) async {
      void _showResult(String baslik, String metin) {
        showDialog(
          context: context,
          builder: (context) {
            return CustomNotification(
              baslik: baslik,
              metin: metin,
            );
          },
        );
      }
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        _showResult(
          Localization.get('hata_baslik'),
          Localization.get('giris_yap_mesaj'),
        );
        return;
      }

      try {
        await Supabase.instance.client.from('feedbacks').insert({
          'sebep': sebep,
          'message': message,
          'isim': AppState.user.name, // Sınıfındaki isim değişkeni
          'user_id': user.id,
        });

        // Başarılı durumu
        _showResult(
            Localization.get('basarili_baslik'),
            Localization.get('feedback_gonderildi')
        );

      } catch (e) {
        // Başarısız durumu
        _showResult(
            Localization.get('hata_baslik'),
            "Error sending message: $e"
        );
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                SizedBox(width: 10),
                Text(
                  'GeoGame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.report, color: Colors.blueAccent),
            title: Text(
              Localization.get('hatabildir'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Localization.get('hatabildir'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            _sebepController,
                            Localization.get('hatabaslik'),
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            _messageController,
                            Localization.get('hatametin'),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  sendMessage(
                                    _sebepController.text,
                                    _messageController.text,
                                  );
                                  _sebepController.clear();
                                  _messageController.clear();
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Text('Gönder'),
                                ),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Text('İptal'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text(
              Localization.get('sikayet'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          Divider(),
          _buildListTile(
            Icons.share,
            Color(0xFF5865F2),
            Localization.get('uygpaylas'),
            () async {
              await Share.share(Localization.get('davetpromt'));
            },
          ),
          _buildListTile(
            Icons.person,
            Color(0xFF5865F2),
            Localization.get('yapimcimetin'),
            () async {
              await EasyLauncher.url(
                url: 'https://keremkk.com.tr',
                mode: Mode.platformDefault,
              );
            },
          ),
          _buildListTile(
            Icons.public,
            Colors.red,
            Localization.get('website'),
            () async {
              await EasyLauncher.url(url: 'https://keremkk.com.tr/geogame');
            },
          ),
          _buildListTile(
            FontAwesomeIcons.github,
            Colors.black,
            Localization.get('github'),
            () async {
              await EasyLauncher.url(
                url: 'https://github.com/KeremKuyucu/GeoGame',
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              Localization.get('yapimci'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          SizedBox(height: 20), // Boşluk bırakır
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    Color iconColor,
    String title,
    Function() onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class CustomNotification extends StatelessWidget {
  final String baslik;
  final String metin;

  CustomNotification({required this.baslik, required this.metin});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue, // Bildirimin rengini değiştirebilirsiniz
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(baslik, style: TextStyle(fontSize: 18, color: Colors.white)),
              SizedBox(height: 10),
              Text(metin, style: TextStyle(fontSize: 16, color: Colors.white)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 4.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Bildirimi kapat
                        },
                        child: Text(
                          Localization.get('tamam'),
                          style: TextStyle(color: Colors.black),
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
            ],
          ),
        ),
      ),
    );
  }
}

bool amerikakitasi = true,
    asyakitasi = true,
    afrikakitasi = true,
    avrupakitasi = true,
    okyanusyakitasi = true,
    antartikakitasi = true,
    bmuyeligi = false,
    sadecebm = false;
int mesafedogru = 0,
    mesafeyanlis = 0,
    bayrakdogru = 0,
    bayrakyanlis = 0,
    baskentdogru = 0,
    baskentyanlis = 0,
    mesafepuan = 0,
    bayrakpuan = 0,
    baskentpuan = 0,
    toplampuan = 0;