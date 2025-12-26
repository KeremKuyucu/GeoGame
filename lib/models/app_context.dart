enum UnFilterStatus {
  all,        // Hepsini göster (Varsayılan)
  onlyUN,     // Sadece BM Üyeleri (Eski: bmuyeligi = true)
  onlyNonUN   // Sadece BM Üyesi Olmayanlar (Eski: sadecebm = true)
}

class GameFilter {
  // Kıtalar
  bool amerika;
  bool asya;
  bool afrika;
  bool avrupa;
  bool okyanusya;
  bool antarktika;

  // Oyun Modu
  bool isButtonMode; // Eski: yazmamodu

  // BM Filtresi (Enum yapısı çakışmayı önler)
  UnFilterStatus unFilter;

  GameFilter({
    this.amerika = true,
    this.asya = true,
    this.afrika = true,
    this.avrupa = true,
    this.okyanusya = true,
    this.antarktika = true,
    this.isButtonMode = true,
    this.unFilter = UnFilterStatus.all,
  });

  // Veritabanı için dönüşüm
  Map<String, dynamic> toMap() {
    return {
      'amerika': amerika,
      'asya': asya,
      'afrika': afrika,
      'avrupa': avrupa,
      'okyanusya': okyanusya,
      'antarktika': antarktika,
      'isButtonMode': isButtonMode,
      'unFilter': unFilter.index, // Enum'ı integer olarak saklarız (0, 1, 2)
    };
  }
}
class AppSettings {
  bool darkTheme;
  String language;
  String languagePref;

  AppSettings({
    this.darkTheme = true,
    this.language = '',
    this.languagePref = '',
  });

  bool get isEnglish => language == 'English';
}
class GameStats {
  int mesafeDogru;
  int mesafeYanlis;
  int bayrakDogru;
  int bayrakYanlis;
  int baskentDogru;
  int baskentYanlis;

  // Puanlar (Hesaplanabilir değerler olmalı ama veritabanında tutuyorsan kalsın)
  int mesafePuan;
  int bayrakPuan;
  int baskentPuan;

  // Toplam puanı değişkende tutmak yerine getter ile hesaplamak daha güvenlidir
  // Eski: toplampuan
  int get totalScore => mesafePuan + bayrakPuan + baskentPuan;

  GameStats({
    this.mesafeDogru = 0,
    this.mesafeYanlis = 0,
    this.bayrakDogru = 0,
    this.bayrakYanlis = 0,
    this.baskentDogru = 0,
    this.baskentYanlis = 0,
    this.mesafePuan = 0,
    this.bayrakPuan = 0,
    this.baskentPuan = 0,
  });
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

class AppState {
  static int selectedIndex = 0;
  static UserProfile user = UserProfile.anonymous();
  static GameFilter filter = GameFilter();
  static AppSettings settings = AppSettings();
  static GameStats stats = GameStats();
}