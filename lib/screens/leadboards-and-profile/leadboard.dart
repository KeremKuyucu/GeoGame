import 'package:GeoGame/util.dart';
import 'package:http/http.dart' as http;

class Leadboard extends StatefulWidget {
  @override
  _LeadboardState createState() => _LeadboardState();
}
class _LeadboardState extends State<Leadboard> {
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    fetchData();
    await readFromFile((update) => setState(update));
  }
  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Leadboard()),
      );
    } else if (selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profiles()),
      );
    } else if (selectedIndex == 3 ) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }
  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://geogame-api.keremkk.com.tr/api/get_leadboard'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

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

          // Kullanıcıları puanlarına göre sıralama
          users.sort((a, b) => b['puan'].compareTo(a['puan']));
        });

        print("Veri başarıyla güncellendi.");
      } else {
        throw Exception('Veri yüklenemedi.');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }
  Color _getBackgroundColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Altın renk
      case 1:
        return Colors.grey[300]!; // Gümüş renk
      case 2:
        return Colors.deepOrangeAccent; // Bronz renk
      default:
        return Colors.blueAccent; // Diğerleri için standart renk
    }
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
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: users.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Userprofile(
                                  userindex: index,
                                )),
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
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              radius: 15,
                              backgroundColor: _getBackgroundColor(index),
                            ),
                            CircleAvatar(
                                backgroundImage: NetworkImage(users[index]
                                        ['profilurl'] ??
                                    'https://cdn.glitch.global/e74d89f5-045d-4ad2-94c7-e2c99ed95318/2815428.png?v=1738114346363'),
                                radius: 30),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    users[index]['name'] ?? 'Unknown Name',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Score: ${users[index]['puan'] ?? '0'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
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
