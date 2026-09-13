import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:geogame/services/localization_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Kodda STATIK olarak kullanılan tüm Localization.t(key) anahtarları.
// Dinamik olanlar (interpolasyon içerenler) bu listeye dahil EDİLMEZ:
//   - 'directions.${sectors[index]}' → directions.* olarak yorumlanır
//   - '${metadata.titleKey}.title'   → oyun başlık şeması (game_*.title/description)
//   - 'profile.$prefix'              → profile.* kategorisi
//
// ÖNEMLİ: Koda yeni bir Localization.t() çağrısı eklendiğinde bu seti güncelle.
// ─────────────────────────────────────────────────────────────────────────────
const Set<String> kUsedKeys = {
  // common
  'common.ok',
  'common.save',
  'common.cancel',
  'common.yes',
  'common.no',
  'common.pass',
  'common.success',
  'common.send',
  'common.error',
  'common.close',
  'common.confirm',
  'common.field_required',

  // nav
  'nav.games',
  'nav.rank',
  'nav.profile',
  'nav.settings',

  // feedback
  'feedback.title',
  'feedback.subject_hint',
  'feedback.message_hint',
  'feedback.sent_success',

  // auth (statik çağrılar)
  'auth.login_required',
  'auth.login',
  'auth.logout',
  'auth.logout_success',
  'auth.login_subtitle',
  'auth.email',
  'auth.login_prompt',
  'auth.login_description',
  'auth.or_divider',
  'auth.google_sign_in',
  'auth.google_login_success',
  'auth.error_google_cancelled',
  'auth.error_google_sign_in',
  'auth.continue_as_guest',
  'auth.login_success',
  'auth.warning_no_account',
  'auth.error_login_failed',
  'auth.reset_password_title',
  'auth.reset_password_desc',
  'auth.send_link',
  'auth.feature_cloud_sync_title',
  'auth.feature_cloud_sync_desc',
  'auth.feature_leaderboard_title',
  'auth.feature_leaderboard_desc',
  'auth.feature_instant_title',
  'auth.feature_instant_desc',

  // game_common
  'game_common.input_hint',
  'game_common.rules',
  'game_common.save_points_warning',
  'game_common.congratulations',
  'game_common.correct_msg',
  'game_common.passed_msg',
  'game_common.clear_guesses',
  'game_common.options_hint',
  'game_common.not_found',
  'game_common.first_guess',
  'game_common.score_system_generic',
  'game_common.new_game',
  'game_common.main_menu',
  'game_common.score',

  // game_intro
  'game_intro.start_game',

  // game_capital
  'game_capital.title',
  'game_capital.content',
  'game_capital.rule_welcome',

  // game_flag
  'game_flag.title',
  'game_flag.rule_welcome',

  // game_distance
  'game_distance.title',
  'game_distance.rule_welcome',
  'game_distance.rule_score',

  // game_borderline
  'game_borderline.title',
  'game_borderline.hint_scale',
  'game_borderline.rule_welcome',

  // game_borderpath
  'game_borderpath.title',
  'game_borderpath.rule_1',
  'game_borderpath.rule_2',
  'game_borderpath.rule_3',
  'game_borderpath.rule_4',
  'game_borderpath.victory_msg',
  'game_borderpath.stat_moves',
  'game_borderpath.stat_optimal',
  'game_borderpath.perf_perfect',
  'game_borderpath.perf_great',
  'game_borderpath.perf_good',
  'game_borderpath.perf_try_harder',
  'game_borderpath.loading_map',
  'game_borderpath.label_start',
  'game_borderpath.label_target',
  'game_borderpath.label_moves',
  'game_borderpath.label_optimal',
  'game_borderpath.current_path',
  'game_borderpath.neighbors_label',
  'game_borderpath.no_neighbors_left',

  // game_findmap
  'game_findmap.title',
  'game_findmap.find_prompt',
  'game_findmap.loading_world',
  'game_findmap.correct_feedback',
  'game_findmap.wrong_feedback',
  'game_findmap.hide_hint',
  'game_findmap.show_hint',
  'game_findmap.reset_view',
  'game_findmap.web_performance_warning',

  // directions (dinamik: directions.${sector})
  'directions.north',
  'directions.north_east',
  'directions.east',
  'directions.south_east',
  'directions.south',
  'directions.south_west',
  'directions.west',
  'directions.north_west',

  // settings
  'settings.title',
  'settings.general_title',
  'settings.selected_theme',
  'settings.lang',
  'settings.multiple_choice_mode',
  'settings.continent_title',
  'settings.un_members',
  'settings.use_anonymous_data',
  'settings.telemetry_dialog_title',
  'settings.telemetry_dialog_message',
  'settings.telemetry_disable',
  'settings.telemetry_cancel',
  'settings.continents.south_america',
  'settings.continents.north_america',
  'settings.continents.asia',
  'settings.continents.africa',
  'settings.continents.europe',
  'settings.continents.oceania',
  'settings.continents.antarctica',
  'settings.guest',
  'settings.child_mode',
  'settings.child_mode_desc',
  'settings.child_mode_enable_title',
  'settings.child_mode_enable_desc',
  'settings.child_mode_disable_title',
  'settings.child_mode_disable_desc',
  'settings.child_mode_pin_hint',
  'settings.child_mode_pin_confirm_hint',
  'settings.child_mode_pin_mismatch',
  'settings.child_mode_pin_length_error',
  'settings.child_mode_wrong_pin',
  'settings.child_mode_leaderboard_disabled_title',
  'settings.child_mode_leaderboard_disabled_desc',
  'settings.no_continent_active',

  // profile (dinamik: profile.$prefix — tüm alt alanlar potential olarak kullanılır)
  'profile.title',
  'profile.stats_title',
  'profile.total_score',
  'profile.correct_label',
  'profile.wrong_label',

  // leaderboard
  'leaderboard.title',
  'leaderboard.no_data',
  'leaderboard.score',
  'leaderboard.load_error',

  // drawer
  'drawer.report_bug',
  'drawer.feedback_note',
  'drawer.my_website',
  'drawer.geogame_website',
  'drawer.geogame_github',
  'drawer.creator',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Service & Language Files', () {
    const expectedLanguages = ['eng', 'tur', 'deu', 'spa', 'fra', 'por', 'rus'];

    test('Localization.languages tüm desteklenen dilleri içermeli', () {
      for (final code in expectedLanguages) {
        expect(Localization.languages.containsKey(code), isTrue,
            reason: '$code Localization.languages içinde bulunamadı');
      }
      expect(Localization.supportedLanguages, containsAll(expectedLanguages));
    });

    test('Tüm dil isimleri doğru tanımlanmış olmalı', () {
      expect(Localization.getDisplayName('eng'), 'English');
      expect(Localization.getDisplayName('tur'), 'Türkçe');
      expect(Localization.getDisplayName('deu'), 'Deutsch');
      expect(Localization.getDisplayName('spa'), 'Español');
      expect(Localization.getDisplayName('fra'), 'Français');
      expect(Localization.getDisplayName('por'), 'Português');
      expect(Localization.getDisplayName('rus'), 'Русский');
    });

    // ─── yardımcı: JSON'dan tüm dot-notation anahtarlarını topla ───────────
    void collectKeys(
        Map<String, dynamic> map, String prefix, Set<String> keys) {
      map.forEach((key, value) {
        final fullKey = prefix.isEmpty ? key : '$prefix.$key';
        if (value is Map<String, dynamic>) {
          collectKeys(value, fullKey, keys);
        } else {
          keys.add(fullKey);
        }
      });
    }

    // ─── Test 1: Tüm dil dosyaları geçerli JSON, eksiksiz ve boş değer yok ─
    test(
        'Tüm dil dosyaları mevcut, geçerli JSON ve eng.json ile aynı anahtarlara sahip olmalı',
        () {
      final engFile = File('assets/lang/eng.json');
      expect(engFile.existsSync(), isTrue);

      final Map<String, dynamic> engMap =
          json.decode(engFile.readAsStringSync());
      final Set<String> engKeys = {};
      collectKeys(engMap, '', engKeys);

      for (final code in expectedLanguages) {
        final langFile = File('assets/lang/$code.json');
        expect(langFile.existsSync(), isTrue,
            reason: '$code.json dosyası mevcut değil');

        final Map<String, dynamic> langMap =
            json.decode(langFile.readAsStringSync());
        final Set<String> langKeys = {};
        collectKeys(langMap, '', langKeys);

        // eng.json içindeki tüm anahtarlar bu dilde de olmalı
        final missingKeys = engKeys.difference(langKeys);
        expect(missingKeys, isEmpty,
            reason: '$code.json içinde eksik anahtarlar var: $missingKeys');

        // Boş değer olmamalı
        void checkNonEmpty(Map<String, dynamic> m, String path) {
          m.forEach((k, v) {
            final p = path.isEmpty ? k : '$path.$k';
            if (v is Map<String, dynamic>) {
              checkNonEmpty(v, p);
            } else if (v is String) {
              expect(v.trim(), isNotEmpty,
                  reason: '$code.json dosyasında $p boş olamaz');
            }
          });
        }

        checkNonEmpty(langMap, '');
      }
    });

    // ─── Test 2: Kullanılmayan anahtar raporu ────────────────────────────────
    //
    // Bu test ASLA fail etmez (sadece printAll ile raporlar).
    // Yeni bir anahtar eklenince üstteki kUsedKeys setine de eklemeyi unutma.
    // Bir anahtar kaldırıldığında veya artık kullanılmadığında JSON'dan da
    // temizlemek için bu raporu kullan.
    test(
        'Kullanılmayan localization anahtarlarını raporla (bilgi amaçlı, fail etmez)',
        () {
      final engFile = File('assets/lang/eng.json');
      expect(engFile.existsSync(), isTrue);

      final Map<String, dynamic> engMap =
          json.decode(engFile.readAsStringSync());
      final Set<String> allJsonKeys = {};
      collectKeys(engMap, '', allJsonKeys);

      // Dinamik kategoriler: bu prefix'e sahip tüm anahtarlar "potansiyel olarak
      // kullanılıyor" sayılır çünkü runtime'da interpolasyon ile seçilirler.
      const dynamicPrefixes = [
        'directions.', // directions.${sectors[index]}
        'game_capital.', // ${metadata.titleKey}.title / .description
        'game_flag.',
        'game_distance.',
        'game_borderline.',
        'game_borderpath.',
        'game_findmap.',
        'profile.', // profile.$prefix (score_display, success_label vb.)
      ];

      final unusedKeys = allJsonKeys.where((key) {
        if (kUsedKeys.contains(key)) return false;
        for (final prefix in dynamicPrefixes) {
          if (key.startsWith(prefix)) return false;
        }
        return true;
      }).toList()
        ..sort();

      if (unusedKeys.isEmpty) {
        // ignore: avoid_print
        print('✅ Kullanılmayan localization anahtarı yok.');
      } else {
        // ignore: avoid_print
        print('⚠️  Muhtemelen kullanılmayan ${unusedKeys.length} anahtar:');
        for (final k in unusedKeys) {
          // ignore: avoid_print
          print('   • $k');
        }
        // ignore: avoid_print
        print(
            '\nNot: Dinamik prefix\'ler (${dynamicPrefixes.join(", ")}) bu listeden hariç tutuldu.');
        // ignore: avoid_print
        print(
            'kUsedKeys setini güncellemek için localization_service_test.dart dosyasını düzenle.');
      }

      // Test her zaman geçer — bu sadece bir envanter raporu.
      expect(true, isTrue);
    });
  });
}


// flutter test test/services/localization_service_test.dart --reporter expanded