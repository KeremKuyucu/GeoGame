import 'package:GeoGame/util.dart';

class Userprofile extends StatefulWidget {
  final int userindex;
  Userprofile({Key? key, required this.userindex}) : super(key: key);
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<Userprofile> {
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }
  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('navigasyonbar2')),
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
              Navigator.pop(context);
            },
          ),
        ],
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
                  // Profil başlığı
                  Text(
                    ('${users[widget.userindex]['name']}'),
                    style: TextStyle(
                      fontSize: 26.0, // Daha büyük başlık
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2, // Harf aralığı ekleyerek şıklık katma
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Divider(
                    color: Colors.white.withOpacity(0.6), // Daha yumuşak divider
                    thickness: 1.2, // Divider'ın kalınlığı
                  ),
                  SizedBox(height: 10.0),

                  // Kullanıcı puanı
                  Text(
                    '${Yazi.get('profil1')} ${users[widget.userindex]['puan']}',
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
                    '${Yazi.get('profil2')} ${users[widget.userindex]['mesafepuan']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil3')} ${users[widget.userindex]['mesafedogru']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil4')} ${users[widget.userindex]['mesafeyanlis']}',
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
                    '${Yazi.get('profil5')} ${users[widget.userindex]['bayrakpuan']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil6')} ${users[widget.userindex]['bayrakdogru']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil7')} ${users[widget.userindex]['bayrakyanlis']}',
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
                    '${Yazi.get('profil8')} ${users[widget.userindex]['baskentpuan']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil9')} ${users[widget.userindex]['baskentdogru']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${Yazi.get('profil10')} ${users[widget.userindex]['baskentyanlis']}',
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
    );
  }
}
