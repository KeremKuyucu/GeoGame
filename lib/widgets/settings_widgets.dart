import 'package:flutter/material.dart';

import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/screens/settings/settings_controller.dart';

/// Hesap bölümü - Guest UI
class SettingsGuestCard extends StatelessWidget {
  final SettingsController controller;
  final bool isDark;
  final VoidCallback onAuthComplete;

  const SettingsGuestCard({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onAuthComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded,
                size: 48, color: Colors.blueAccent),
          ),
          const SizedBox(height: 16),
          Text(
            Localization.t('settings.guest'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Localization.t('auth.login_description'),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.navigateToAuth(context);
                    onAuthComplete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "${Localization.t('auth.login')} / ${Localization.t('auth.signup')}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hesap bölümü - Profile UI
class SettingsProfileCard extends StatelessWidget {
  final SettingsController controller;
  final bool isDark;
  final VoidCallback onSignOut;
  final VoidCallback onEditComplete;

  const SettingsProfileCard({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onSignOut,
    required this.onEditComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(AppState.user.avatarUrl),
              onBackgroundImageError: (_, __) {},
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppState.user.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    await controller.navigateToEditProfile(context);
                    onEditComplete();
                  },
                  child: Row(
                    children: [
                      Text(
                        Localization.t('settings.edit_profile'),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: Colors.blueAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: Localization.t('auth.logout'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ayar tile widget'ı
class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: isSwitch
          ? Switch.adaptive(
              value: switchValue,
              onChanged: onSwitchChanged,
              activeThumbColor: Colors.green,
            )
          : const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.grey),
    );
  }
}

/// Bölüm başlığı
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Ayarlar container'ı
class SettingsContainer extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const SettingsContainer({
    super.key,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

/// Ayarlar divider'ı
class SettingsDivider extends StatelessWidget {
  final bool isDark;

  const SettingsDivider({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }
}

/// Versiyon bilgisi
class SettingsVersionInfo extends StatelessWidget {
  final bool isDark;
  final String version;

  const SettingsVersionInfo({
    super.key,
    required this.isDark,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            "GeoGame",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          Text(
            "v$version",
            style: TextStyle(
              color: isDark ? Colors.grey[700] : Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dil seçici widget'ı
class SettingsLanguageTile extends StatelessWidget {
  final SettingsController controller;
  final bool isDark;
  final VoidCallback onLanguageChanged;

  const SettingsLanguageTile({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String currentValue = controller.currentLanguage;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            const Icon(Icons.language_rounded, color: Colors.white, size: 20),
      ),
      title: Text(
        Localization.t('settings.lang'),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: Localization.supportedLanguages.contains(currentValue)
                  ? currentValue
                  : 'eng',
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              items: Localization.supportedLanguages
                  .map((String code) => DropdownMenuItem(
                        value: code,
                        child: Text(
                          Localization.getDisplayName(code),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  await controller.changeLanguage(newValue, context);
                  onLanguageChanged();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
