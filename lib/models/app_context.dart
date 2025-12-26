// lib/models/app_context.dart

class AppState {
  static int selectedIndex = 0;
  static UserProfile user = UserProfile.anonymous();
  static GameFilter filter = GameFilter();
  static AppSettings settings = AppSettings();
  static GameStats stats = GameStats();
  static GameSession session = GameSession();
}

class UserProfile {
  String name;
  String avatarUrl;

  UserProfile({
    required this.name,
    required this.avatarUrl,
  });

  factory UserProfile.anonymous() {
    return UserProfile(
      name: 'Misafir',
      avatarUrl: 'https://geogame-cdn.keremkk.com.tr/anon.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Misafir',
      avatarUrl: map['avatarUrl'] ?? 'https://geogame-cdn.keremkk.com.tr/anon.png',
    );
  }
}

class GameFilter {
  bool northAmerica, southAmerica, Asia, Africa, Europe, Oceania, Antarctic;
  bool includeNonUN;
  bool isButtonMode;

  GameFilter({
    this.northAmerica = true,
    this.southAmerica = true,
    this.Asia = true,
    this.Africa = true,
    this.Europe = true,
    this.Oceania = true,
    this.Antarctic = true,
    this.isButtonMode = true,
    this.includeNonUN = false,
  });

  factory GameFilter.fromMap(Map<String, dynamic> map) {
    return GameFilter(
      northAmerica: map['northAmerica'] ?? true,
      southAmerica: map['southAmerica'] ?? true,
      Asia: map['Asia'] ?? true,
      Africa: map['Africa'] ?? true,
      Europe: map['Europe'] ?? true,
      Oceania: map['Oceania'] ?? true,
      Antarctic: map['Antarctic'] ?? true,
      isButtonMode: map['isButtonMode'] ?? true,
      includeNonUN: map['includeNonUN'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'southAmerica': southAmerica,
      'northAmerica': northAmerica,
      'Asia': Asia,
      'Africa': Africa,
      'Europe': Europe,
      'Oceania': Oceania,
      'Antarctic': Antarctic,
      'isButtonMode': isButtonMode,
      'includeNonUN': includeNonUN,
    };
  }
}

class AppSettings {
  bool darkTheme;
  String language; // Dil kodu (tr, en)
  String languagePref; // Cihaz tercihi vs.

  AppSettings({
    this.darkTheme = true,
    this.language = '',
    this.languagePref = '',
  });

  bool get isEnglish => language == 'en'; // Kod 'en' ise İngilizce

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      darkTheme: map['darkTheme'] ?? true,
      language: map['language'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'darkTheme': darkTheme,
      'language': language,
    };
  }
}

class GameStats {
  int distanceCorrectCount, distanceWrongCount;
  int flagCorrectCount, flagWrongCount;
  int capitalCorrectCount, capitalWrongCount;

  int distanceScore, flagScore, capitalScore;

  int get totalScore => distanceScore + flagScore + capitalScore;

  GameStats({
    this.distanceCorrectCount = 0, this.distanceWrongCount = 0,
    this.flagCorrectCount = 0, this.flagWrongCount = 0,
    this.capitalCorrectCount = 0, this.capitalWrongCount = 0,
    this.distanceScore = 0, this.flagScore = 0, this.capitalScore = 0,
  });

  factory GameStats.fromMap(Map<String, dynamic> map) {
    return GameStats(
      distanceCorrectCount: map['distanceCorrectCount'] ?? 0,
      distanceWrongCount:   map['distanceWrongCount'] ?? 0,

      flagCorrectCount:     map['flagCorrectCount'] ?? 0,
      flagWrongCount:       map['flagWrongCount'] ?? 0,

      capitalCorrectCount:  map['capitalCorrectCount'] ?? 0,
      capitalWrongCount:    map['capitalWrongCount'] ?? 0,

      distanceScore:        map['distanceScore'] ?? 0,
      flagScore:            map['flagScore'] ?? 0,
      capitalScore:         map['capitalScore'] ?? 0,
    );
  }
}
class GameSession {
  // Puanlar
  int totalScore = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int passCount = 0;

  String sessionId = "";

  int _startScore = 50;
  int _minScore = 20;
  int currentQuestionScore = 50;

  void reset({required int startScore, required int minScore}) {
    totalScore = 0;
    correctCount = 0;
    wrongCount = 0;
    passCount = 0;

    sessionId = "${DateTime.now().millisecondsSinceEpoch}-${(100 + (DateTime.now().microsecond % 900))}";

    _startScore = startScore;
    _minScore = minScore;
    currentQuestionScore = _startScore;
  }

  void nextQuestion() {
    currentQuestionScore = _startScore;
  }

  void submitCorrect() {
    correctCount++;
    totalScore += currentQuestionScore;
    nextQuestion();
  }

  void submitWrong() {
    wrongCount++;
    currentQuestionScore -= 10;
    if (currentQuestionScore < _minScore) {
      currentQuestionScore = _minScore;
    }
  }

  void submitPass() {
    passCount++;
    nextQuestion();
  }
}