import 'package:flutter/foundation.dart';

import 'package:geogame/models/countries.dart';
import 'package:geogame/models/game_metadata.dart';
import 'package:geogame/services/localization_service.dart';

class AppState extends ChangeNotifier {
  static int selectedIndex = 0;
  static String version = '';

  static UserProfile user = UserProfile.anonymous();
  static Country targetCountry = Country.empty();
  static Country tempCountry = Country.empty();
  static List<Country> allCountries = [];
  static List<Country> activePool = [];

  static String getGameModeKey(GameType type) => switch (type) {
        GameType.flag => 'flag',
        GameType.capital => 'capital',
        GameType.distance => 'distance',
        GameType.borderline => 'borderline',
        GameType.borderpath => 'borderpath',
        GameType.findmap => 'findmap',
      };
}

class UserProfile {
  String name;
  String avatarUrl;

  UserProfile({required this.name, required this.avatarUrl});

  factory UserProfile.anonymous() => UserProfile(
        name: Localization.t('settings.guest'),
        avatarUrl: 'https://robohash.org/',
      );

  Map<String, dynamic> toMap() => {'name': name, 'avatarUrl': avatarUrl};

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] ?? Localization.t('settings.guest'),
        avatarUrl: map['avatarUrl'] ?? 'https://robohash.org/',
      );
}
