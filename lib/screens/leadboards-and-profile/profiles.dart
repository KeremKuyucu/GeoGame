import 'package:GeoGame/util.dart';

class Profiles extends StatefulWidget {
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  @override
  void initState() {
    super.initState();
    setState(() {
      _initializeGame();
    });
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
  }

  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Ulkelerlist()),
      );
    } else if (selectedIndex == 3) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 4) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('navigasyonbar4')),
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
      body: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 15.0, // Daha belirgin gölge
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0), // Daha yuvarlak köşeler
        ),
        shadowColor: Colors.black.withOpacity(0.3), // Daha derin gölge
        color: Colors.grey.shade800, // Koyu, şık bir arka plan rengi
        child: Container(
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0), // Yuvarlak köşe
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade900], // Sofistike renk geçişi
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil başlığı ve profil resmi
                  Row(
                    children: [
                      // Profil Resmi
                      CircleAvatar(
                        radius: 25.0, // Profil resmi boyutu
                        backgroundImage: NetworkImage(profilurl)
                      ),
                      SizedBox(width: 10.0),
                      // Kullanıcı adı
                      Text(
                        ('$name'),
                        style: TextStyle(
                          fontSize: 26.0, // Daha büyük başlık
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2, // Harf aralığı ekleyerek şıklık katma
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  SizedBox(height: 10.0),

                  // Kullanıcı puanı
                  Text(
                    '${Yazi.get('profil1')} $toplampuan',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10.0),

                  // Mesafe puan doğru / yanlış
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  Text(
                    '${Yazi.get('profil2')} $mesafepuan',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil3')} $mesafedogru',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil4')} $mesafeyanlis',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  // Bayrak puan doğru / yanlış
                  Text(
                    '${Yazi.get('profil5')} $bayrakpuan',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil6')} $bayrakdogru',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil7')} $bayrakyanlis',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  // Başkent puan doğru / yanlış
                  Text(
                    '${Yazi.get('profil8')} $baskentpuan',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil9')} $baskentdogru',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil10')} $baskentyanlis',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}
