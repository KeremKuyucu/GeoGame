import 'package:GeoGame/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Locale deviceLocale = PlatformDispatcher.instance.locale;
  diltercihi = deviceLocale.languageCode;
  runApp(Geogame());
}
class Geogame extends StatefulWidget {
  @override
  State<Geogame> createState() => GeoGame();
}

class GeoGame extends State<Geogame> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeBuilder(
      builder: (BuildContext context, ThemeMode themeMode) {
        return MaterialApp(
        debugShowCheckedModeBanner: false,
          title: "GeoGame",
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: Colors.red,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: Colors.deepPurple,
            ),
          ),
          home: GeoGameLobi(),
        );
      },
    );
  }
}


/*
flutter pub run flutter_launcher_icons:main

flutter build apk --release --split-per-abi
flutter build windows

 */