import 'package:flutter/material.dart';

import 'package:geogame/services/auth_service.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/services/name_filter_service.dart';

class EditProfileController {
  String? uid;
  bool isLoading = false;

  Future<void> loadUserProfile(
    TextEditingController nameController,
    TextEditingController emailController,
  ) async {
    final user = AuthService.currentUser;
    if (user != null) {
      uid = user.id;
      emailController.text = user.email ?? '';

      final metadata = user.userMetadata;
      if (metadata != null) {
        nameController.text = metadata['full_name'] ?? '';
      }
      debugPrint("✅ Kullanıcı bilgileri cache'den başarıyla okundu.");
    }
  }

  bool get isUserAvailable => AuthService.currentUser != null;

  Future<String?> updateProfile(String name) async {
    if (uid == null) return 'User not found';

    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length < 2) {
      return Localization.t('auth.name_too_short');
    }

    // İsim filtresi kontrolü
    final filterError = NameFilterService.validate(trimmedName);
    if (filterError != null) {
      return Localization.t('edit_profile.$filterError');
    }

    final String avatarUrl = 'https://robohash.org/$uid';

    final String? error = await AuthService.updateProfileMetadata(
      name: trimmedName,
      avatarUrl: avatarUrl,
    );

    if (error == null) {
      await AuthService.syncUserData(AuthService.currentUser!);
    }

    return error;
  }

  Future<String?> changeEmail(String newEmail) async {
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      return Localization.t('auth.invalid_email');
    }

    return await AuthService.updateEmail(newEmail);
  }

  Future<String?> changePassword(String newPassword) async {
    if (newPassword.isEmpty) {
      return Localization.t('common.field_required');
    }

    return await AuthService.updatePassword(newPassword);
  }

  String getAvatarUrl() {
    if (uid != null) {
      return 'https://robohash.org/$uid';
    }
    return 'https://robohash.org/default';
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.redAccent
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
