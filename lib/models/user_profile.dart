// lib/models/user_profile.dart

class UserProfile {
  String name;
  String avatarUrl;

  UserProfile({
    required this.name,
    required this.avatarUrl,
  });

  factory UserProfile.anonymous() => UserProfile(
        name: '',
        avatarUrl: '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] ?? '',
        avatarUrl: map['avatarUrl'] ?? '',
      );
}
