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
            child: const Icon(Icons.explore_rounded,
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
                    Localization.t('auth.login'),
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

  const SettingsProfileCard({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = AppState.user.avatarUrl.trim().isNotEmpty;

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
              backgroundImage: hasAvatar
                  ? ResizeImage(
                      NetworkImage(AppState.user.avatarUrl),
                      width: 140,
                      height: 140,
                    )
                  : null,
              onBackgroundImageError: hasAvatar ? (_, __) {} : null,
              backgroundColor: isDark
                  ? const Color(0xFF2C2C3E)
                  : Colors.grey[200],
              child: !hasAvatar
                  ? Text(
                      AppState.user.name.isNotEmpty
                          ? AppState.user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    )
                  : null,
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_circle_outlined,
                              size: 14, color: Colors.blueAccent),
                          SizedBox(width: 4),
                          Text(
                            'Google Account',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            )
          : null,
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isDark ? const Color(0xFFBB86FC) : const Color(0xFF6200EE),
          letterSpacing: 1.2,
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
        color: isDark
            ? const Color(0xFF1E1E2C).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
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
      thickness: 0.8,
      indent: 56,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
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
        constraints: const BoxConstraints(maxWidth: 130),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: Localization.supportedLanguages.contains(currentValue)
                  ? currentValue
                  : 'eng',
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              dropdownColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
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

/// Tema seçici widget'ı
class SettingsThemeTile extends StatelessWidget {
  final SettingsController controller;
  final bool isDark;
  final VoidCallback onThemeChanged;

  const SettingsThemeTile({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String currentTheme = controller.themeMode;

    IconData themeIcon;
    Color iconBgColor;
    if (currentTheme == 'dark') {
      themeIcon = Icons.dark_mode_rounded;
      iconBgColor = Colors.deepPurple;
    } else if (currentTheme == 'light') {
      themeIcon = Icons.light_mode_rounded;
      iconBgColor = Colors.amber.shade700;
    } else {
      themeIcon = Icons.brightness_auto_rounded;
      iconBgColor = Colors.indigo;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(themeIcon, color: Colors.white, size: 20),
      ),
      title: Text(
        Localization.t('settings.theme'),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: ['system', 'light', 'dark'].contains(currentTheme)
                  ? currentTheme
                  : 'system',
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              dropdownColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(
                    Localization.t('settings.theme_system'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'light',
                  child: Text(
                    Localization.t('settings.theme_light'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'dark',
                  child: Text(
                    Localization.t('settings.theme_dark'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  await controller.setThemeMode(newValue);
                  onThemeChanged();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
