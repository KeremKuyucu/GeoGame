import 'package:GeoGame/util.dart';

class Ulkelerlist extends StatefulWidget {
  @override
  _UlkelerlistState createState() => _UlkelerlistState();
}

class _UlkelerlistState extends State<Ulkelerlist> {
  TextEditingController _searchController = TextEditingController();
  List<Ulkeler> filteredUlke = [];
  List<dynamic> users = [];
  @override
  void initState() {
    super.initState();
    filteredUlke = ulke;

    // Arama işlemi için dinleyici ekle
    _searchController.addListener(() {
      setState(() {
        filteredUlke = ulke
            .where((u) => u.isim.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
    _initializeGame();
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
          title: Text(Yazi.get('navigasyonbar3')),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Arama Çubuğu
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Yazi.get('ulkeara'),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              // Kaydırma Çubuğu ile Liste
              Expanded(
                child: filteredUlke.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : Scrollbar(
                  thumbVisibility: true, // Kaydırma çubuğu görünürlüğü
                  child: ListView.builder(
                    itemCount: filteredUlke.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          kalici= filteredUlke[index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UlkelerProfiles()),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.asset(
                                      filteredUlke[index].bayrak,
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                      errorBuilder: (context, error, stackTrace) {
                                        return ClipOval(
                                          child: Image.network(
                                            filteredUlke[index].url,
                                            fit: BoxFit.cover,
                                            width: 60,
                                            height: 60,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  'İnternet Hatası',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isEnglish ? filteredUlke[index].enisim : filteredUlke[index].isim,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) async {
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
