import 'package:GeoGame/util.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = firebase_auth.FirebaseAuth.instance;
  firebase_auth.User? _user;

  @override
  void initState() {
    super.initState();
    readFromFile((update) => setState(update));
    _checkCurrentUser();
    if (getSelectableCountryCount() < 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _kitaUyari();
      });
    }
  }

  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Ulkelerlist()),
      );
    } else if (selectedIndex == 3 && getSelectableCountryCount() > 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 4 || getSelectableCountryCount() < 1) {
      selectedIndex == 4;
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }
  void restartApp() {
    selectedIndex = 0;
    Yazi.loadDil(secilenDil);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GeoGameLobi()),
    );
  }
  Future<void> puanguncelle() async {
    try {
      final response = await http.get(
        Uri.parse('${apiserver}/get_leadboard'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          users = data['users'].map((user) {
            return {
              'name': user['name'] ?? '',
              'uid': user['uid'] ?? '',
              'profilurl': user['profilurl'] ??
                  'https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363',
              'puan': int.parse(user['puan'] ?? "0"),
              'mesafepuan': int.tryParse(user['mesafepuan'] ?? '0') ?? 0,
              'baskentpuan': int.tryParse(user['baskentpuan'] ?? '0') ?? 0,
              'bayrakpuan': int.tryParse(user['bayrakpuan'] ?? '0') ?? 0,
              'mesafedogru': int.tryParse(user['mesafedogru'] ?? '0') ?? 0,
              'baskentdogru': int.tryParse(user['baskentdogru'] ?? '0') ?? 0,
              'bayrakdogru': int.tryParse(user['bayrakdogru'] ?? '0') ?? 0,
              'mesafeyanlis': int.tryParse(user['mesafeyanlis'] ?? '0') ?? 0,
              'baskentyanlis': int.tryParse(user['baskentyanlis'] ?? '0') ?? 0,
              'bayrakyanlis': int.tryParse(user['bayrakyanlis'] ?? '0') ?? 0,
            };
          }).toList();

          for (var user in users) {
            if (user['uid'] == _user?.uid) {
              debugPrint('uidler eşleşti');
              if (toplampuan < user['puan']) {
                debugPrint('puan daha düşük güncellendi');
                toplampuan = user['puan'];
                mesafepuan = user['mesafepuan'];
                baskentpuan = user['baskentpuan'];
                bayrakpuan = user['bayrakpuan'];
                mesafedogru = user['mesafedogru'];
                baskentdogru = user['baskentdogru'];
                bayrakdogru = user['bayrakdogru'];
                mesafeyanlis = user['mesafeyanlis'];
                baskentyanlis = user['baskentyanlis'];
                bayrakyanlis = user['bayrakyanlis'];
                writeToFile();
              }
              break;
            }
          }
        });

        print("Veri başarıyla güncellendi.");
      } else {
        throw Exception('Veri yüklenemedi.');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }
  Future<void> _kitaUyari() async {
    Yazi.loadDil(secilenDil);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kitayari')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('kitayari1')),
                Text(Yazi.get('kitayari2')),
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
  Future<firebase_auth.User?> googleSignIn() async {
    try {
      await GoogleSignIn().signOut();

      // Google hesabı ile oturum açma ekranını göster
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // Kullanıcı oturum açmayı iptal etti
        debugPrint("Kullanıcı oturum açmayı iptal etti.");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // setState ile kullanıcıyı güncelle
      setState(() {
        _user = user;
        puanguncelle();
      });

      String isim;
      String email = "";
      if (user != null) {
        isim = user.displayName ?? "Kullanıcı Adı";
        uid = user.uid;
        email = user.email ?? "";
        name = user.displayName!;
        profilurl = user.photoURL!;
        writeToFile();
      } else {
        isim = "Error";
      }

      // API'ye kullanıcı bilgilerini gönder
      try {
        final targetUrl = '${apiserver}/geogamesignlog';
        final response = await http
            .post(
              Uri.parse(targetUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'sebep': 'Giriş',
                'email': email,
                'name': isim,
              }),
            )
            .timeout(Duration(seconds: 30));

        if (response.statusCode == 200) {
          debugPrint('Mesaj başarıyla gönderildi!');
        } else {
          debugPrint('Mesaj gönderilemedi: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Hata: $e');
      }

      return user;
    } catch (error) {
      debugPrint("Google Sign-In Hatası: $error");
      return null;
    }
  }
  Future<void> signOut() async {
    final user = _auth.currentUser;
    String isim ="";
    String email = "";
    if (user != null) {
      isim = user.displayName ?? "Misafir";
      email = user.email ?? "Misafir@";
      name = '';
      uid = '';
      profilurl =
          'https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363';
      toplampuan = 0;
      mesafepuan = 0;
      baskentpuan = 0;
      bayrakpuan = 0;
      mesafedogru = 0;
      baskentdogru = 0;
      bayrakdogru = 0;
      mesafeyanlis = 0;
      baskentyanlis = 0;
      bayrakyanlis = 0;
      writeToFile();
    } else {
      isim = "Error";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user == null
              ? 'Zaten giriş yapmadınız.'
              : '"${user.displayName?.isEmpty ?? true ? "Misafir" : user.displayName!}" adlı hesaptan çıkış yaptınız.',
        ),
      ),
    );
    _auth.signOut();
    setState(() => this._user = null);
    try {
      final targetUrl = '${apiserver}/geogamesignlog';
      final response = await http
          .post(
            Uri.parse(targetUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'sebep': "Çıkış",
              'email': email,
              'name': isim,
            }),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint('Mesaj başarıyla gönderildi!');
      } else {
        debugPrint('Mesaj gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }
  Future<firebase_auth.User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();

      setState(() {
        _user = userCredential.user;
        name = "Misafir";
        writeToFile();
      });
        try {
          final targetUrl = '${apiserver}/geogamesignlog';
          final response = await http
              .post(
            Uri.parse(targetUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'sebep': 'Misafir Giriş',
              'email': "Misafir@",
              'name': "Misafir",
            }),
          )
              .timeout(Duration(seconds: 30));

          if (response.statusCode == 200) {
            debugPrint('Mesaj başarıyla gönderildi!');
          } else {
            debugPrint('Mesaj gönderilemedi: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Hata: $e');
        }
      return userCredential.user;
    } catch (e) {
      print("Anonim giriş hatası: $e");
      return null;
    }

  }
  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
    debugPrint('user=$_user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('ayarlar')),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
                color: Colors.grey.shade900,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade800, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kullanıcı giriş yapmamışsa
                      if (_user == null) ...[
                        Center(
                          child: ElevatedButton(
                            onPressed: googleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Buton rengi
                            ),
                            child: Text("Google ile Giriş Yap"),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: signInAnonymously,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Buton rengi
                            ),
                            child: Text("Misafir Devam Et"),
                          ),
                        ),
                      ],

                      // Kullanıcı giriş yapmışsa
                      if (_user != null) ...[
                        // Profil Resmi
                        Center(
                          child: CircleAvatar(
                            radius: 60.0,
                            backgroundImage: NetworkImage(profilurl),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Kullanıcı Adı
                        Center(
                          child: Text(
                            name,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Çıkış Butonu
                        Center(
                          child: ElevatedButton(
                            onPressed: signOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Çıkış butonunun rengi
                            ),
                            child: Text("Çıkış Yap"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Yazi.get('digerayarlar'),
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ), // baslık
              buildSwitch(Yazi.get('siklimod'), yazmamodu, (value) {
                setState(() {
                  yazmamodu = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('tema') + (darktema ? 'Dark' : 'Light'), darktema, (value) {
                setState(() {
                  darktema = value;
                  if (darktema)
                    ThemeModeBuilderConfig.setDark();
                  else
                    ThemeModeBuilderConfig.setLight();
                  writeToFile();
                });
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Yazi.get('dil'), style: TextStyle(fontSize: 16.0)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: DropdownButton<String>(
                        hint: Text(secilenDil),
                        isExpanded: true,
                        items: diller.map((String dil) {
                          return DropdownMenuItem<String>(
                            value: dil,
                            child: Text(dil),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            secilenDil = value.toString();
                            writeToFile();
                          });
                          restartApp();
                        },
                      ),
                    ),
                  ),
                ],
              ), // dil değiştirme
              if (secilenDil != "Türkçe")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'If there is a translation error,',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'please report the error.',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'The translations are machine translations.',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ), // makine çeviri uyarısı
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Yazi.get('kitasecenek'),
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ), // baslık
              buildSwitch(Yazi.get('sadecebm'), sadecebm, (value) {
                setState(() {
                  sadecebm = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('amerika'), amerikakitasi, (value) {
                setState(() {
                  amerikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('asya'), asyakitasi, (value) {
                setState(() {
                  asyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('afrika'), afrikakitasi, (value) {
                setState(() {
                  afrikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('avrupa'), avrupakitasi, (value) {
                setState(() {
                  avrupakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('okyanusya'), okyanusyakitasi, (value) {
                setState(() {
                  okyanusyakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('antartika'), antartikakitasi, (value) {
                setState(() {
                  antartikakitasi = value;
                  writeToFile();
                });
              }),
              buildSwitch(Yazi.get('bmuyelik'), bmuyeligi, (value) {
                setState(() {
                  bmuyeligi = value;
                  writeToFile();
                });
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            if (getSelectableCountryCount() > 0) selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}

Widget buildSwitch(
    String title, bool currentValue, ValueChanged<bool> onChanged) {
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
