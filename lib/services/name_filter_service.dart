import 'package:profanity_filter/profanity_filter.dart';

/// Kullanıcı isimlerini filtrelemek ve doğruluk denetimi yapmak için servis.
class NameFilterService {
  static final ProfanityFilter _filter = ProfanityFilter.filterAdditionally(_turkishBadWords);

  /// Türkçe yasaklı kelimeler listesi
  static const List<String> _turkishBadWords = [
    'amk', 'aq', 'oc', 'orospu', 'pic', 'sik', 'yarrak', 'got', 'meme',
    'tasak', 'gavat', 'pezevenk', 'kahpe', 'ibne', 'dol', 'sikik', 'amcik',
    'sikerim', 'anani', 'skrm', 'mk', 'sg', 'bok', 'gerizekali', 'salak',
    'aptal', 'mal', 'dangalak', 'hiyar', 'pust', 'kaltak', 'surtuk', 'kevase',
    'yarak', 'sikem', 'sokam', 'sokarim', 'amq', 'amguard', 'yarag',
    // Yaygın türevler ve birleşik formlar
    'sikici', 'orosbucocu', 'amkoyim', 'amina', 'gotunu', 'siktir',
    'picleri', 'gavatlık', 'orospucocugu', 'anasini', 'ananizi',
  ];

  /// Leetspeak (Harf yerine rakam/sembol kullanımı) dönüşüm haritası
  static const Map<String, String> _leetspeakMap = {
    '4': 'a', '@': 'a',
    '8': 'b',
    '3': 'e',
    '6': 'g', '9': 'g',
    '1': 'i', '!': 'i', '|': 'i',
    '0': 'o',
    '5': 's', '\$': 's',
    '7': 't', '+': 't',
    'v': 'u',
    '2': 'z',
  };

  /// Benzer görünen Unicode karakterleri Latin karşılıklarına dönüştürür.
  /// Kiril, Yunan ve diğer alfabelerdeki homoglyphleri yakalar.
  static const Map<String, String> _homoglyphMap = {
    // Kiril homoglyphler
    'а': 'a', 'А': 'a', // Cyrillic A
    'в': 'b', 'В': 'b', // Cyrillic VE
    'с': 'c', 'С': 'c', // Cyrillic ES
    'е': 'e', 'Е': 'e', // Cyrillic IE
    'і': 'i', 'І': 'i', // Cyrillic I (Ukrainian)
    'к': 'k', 'К': 'k', // Cyrillic KA
    'м': 'm', 'М': 'm', // Cyrillic EM
    'о': 'o', 'О': 'o', // Cyrillic O
    'р': 'p', 'Р': 'p', // Cyrillic ER
    'т': 't', 'Т': 't', // Cyrillic TE
    'х': 'x', 'Х': 'x', // Cyrillic HA
    'у': 'y', 'У': 'y', // Cyrillic U
    // Yaygın sembol homoglyphler
    'ℓ': 'l',
    'ⅰ': 'i', 'ⅱ': 'ii',
  };

  /// Türkçe karakterleri İngilizce karşılıklarına dönüştürür (Karşılaştırma tutarlılığı için)
  static String _normalizeTurkishChars(String input) {
    return input
        .replaceAll('ç', 'c').replaceAll('Ç', 'c')
        .replaceAll('ğ', 'g').replaceAll('Ğ', 'g')
        .replaceAll('ı', 'i').replaceAll('İ', 'i')
        .replaceAll('ö', 'o').replaceAll('Ö', 'o')
        .replaceAll('ş', 's').replaceAll('Ş', 's')
        .replaceAll('ü', 'u').replaceAll('Ü', 'u');
  }

  /// Unicode homoglyphleri standart Latin harflerine dönüştürür.
  static String _normalizeHomoglyphs(String input) {
    String result = input;
    _homoglyphMap.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  /// Zero-width ve görünmez Unicode karakterleri temizler.
  static String _stripInvisibleChars(String input) {
    // Zero-width space, zero-width joiner, zero-width non-joiner,
    // soft hyphen, word joiner, ve diğer görünmez karakterler
    return input.replaceAll(RegExp(
      '[\u200B\u200C\u200D\u200E\u200F\uFEFF\u00AD\u2060\u180E\u202A-\u202E\u2066-\u2069]',
    ), '');
  }

  /// Metindeki Leetspeak karakterleri standart harflere dönüştürür.
  static String _decodeLeetspeak(String input) {
    String decoded = input;
    _leetspeakMap.forEach((key, value) {
      decoded = decoded.replaceAll(key, value);
    });
    return decoded;
  }

  /// Ardışık tekrarlanan karakterleri teke düşürür.
  /// Örn: "siiiiik" → "sik", "ammmk" → "amk"
  static String _collapseRepeats(String input) {
    return input.replaceAll(RegExp(r'(.)\1+'), r'$1');
  }

  /// Unicode combining mark'ları (aksan işaretleri vb.) temizler.
  /// Örn: "s̈ik" → "sik"
  static String _stripCombiningMarks(String input) {
    // Unicode combining diacritical marks aralığı: U+0300–U+036F
    return input.replaceAll(RegExp(r'[\u0300-\u036F]'), '');
  }

  /// İsmin uygunsuz kelime, Leetspeak veya gizlenmiş küfür içerip içermediğini denetler.
  static bool containsProfanity(String name) {
    // 0. Görünmez karakterleri ve combining mark'ları temizle
    String clean = _stripInvisibleChars(name.toLowerCase().trim());
    clean = _stripCombiningMarks(clean);

    // 1. Türkçe karakter ve homoglyph normalizasyonu
    String normalized = _normalizeTurkishChars(clean);
    normalized = _normalizeHomoglyphs(normalized);

    // Doğrudan kontrolden geçir
    if (_filter.hasProfanity(normalized)) return true;

    // 2. Leetspeak çözümlemesi yap (Örn: s1k3r1m -> sikerim)
    String decoded = _decodeLeetspeak(normalized);
    if (_filter.hasProfanity(decoded)) return true;

    // 3. Özel karakter ve boşlukları silerek kontrol et (Örn: p.i.c -> pic)
    //    Sadece ASCII Latin harf ve rakamları tut — tüm Unicode sembollerini de siler
    String condensed = decoded.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (_filter.hasProfanity(condensed)) return true;

    // 4. Ardışık tekrarlanan karakterleri sıkıştırarak kontrol et (Örn: siiiiik -> sik)
    String collapsed = _collapseRepeats(condensed);
    if (_filter.hasProfanity(collapsed)) return true;

    return false;
  }

  /// Telefon numarası, E-posta veya Web sitesi gibi kişisel verileri tespit eder.
  static bool containsContactInfo(String name) {
    final cleanName = name.replaceAll(RegExp(r'\s+'), '');

    // Telefon numaraları (Örn: 05xx..., 5xx..., +905xx...)
    final phoneRegex = RegExp(r'(\+?90|0)?5\d{9}', caseSensitive: false);

    // E-posta adresleri
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', caseSensitive: false);

    // Bağlantılar (http, www, .com, .net vb.)
    final urlRegex = RegExp(r'(https?:\/\/|www\.)|[a-zA-Z0-9-]+\.(com|net|org|io|gg|me|co)', caseSensitive: false);

    return phoneRegex.hasMatch(cleanName) ||
           emailRegex.hasMatch(cleanName) ||
           urlRegex.hasMatch(cleanName);
  }

  /// İsim validasyonu yapar.
  /// Uygunsa null, değilse ilgili hatayı döndürür.
  static String? validate(String name) {
    final trimmed = name.trim();

    if (trimmed.length < 2) {
      return null; // Alt sınır kontrolü harici yapılıyor
    }

    if (trimmed.length > 20) {
      return 'name_too_long';
    }

    // Sadece harf, rakam, boşluk, çizgi ve alt çizgi izin ver
    final validChars = RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ0-9 _-]+$');
    if (!validChars.hasMatch(trimmed)) {
      return 'name_invalid_chars';
    }

    // Telefon, E-posta veya Link denetimi
    if (containsContactInfo(trimmed)) {
      return 'name_contact_info_forbidden';
    }

    // Küfür ve Argo denetimi
    if (containsProfanity(trimmed)) {
      return 'name_inappropriate';
    }

    return null;
  }
}