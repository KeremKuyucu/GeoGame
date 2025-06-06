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


adb install build\app\outputs\flutter-apk\app-release.apk

flutter build apk
xcopy /Y /I "build\app\outputs\flutter-apk\app-release.apk" "C:\Users\KeremK\Desktop\GeoGame-Mobile.apk"
flutter build windows
xcopy /E /I "build\windows\x64\runner\Release" "C:\Users\KeremK\Desktop\GeoGame"
flutter build web


flutter build apk --release --split-per-abi
flutter build windows
xcopy /E /I "build\windows\x64\runner\Release" "C:\Users\KeremK\Desktop\GeoGame"

flutter build apk --release --split-per-abi
flutter build windows

 */