import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales
enum SupportedLocale {
  ja(Locale('ja', 'JP'), '日本語'),
  en(Locale('en', 'US'), 'English'),
  zh(Locale('zh', 'CN'), '简体中文'),
  ko(Locale('ko', 'KR'), '한국어'),
  th(Locale('th', 'TH'), 'ไทย'),
  vi(Locale('vi', 'VN'), 'Tiếng Việt'),
  id(Locale('id', 'ID'), 'Bahasa Indonesia'),
  tl(Locale('tl', 'PH'), 'Filipino');

  final Locale locale;
  final String displayName;

  const SupportedLocale(this.locale, this.displayName);

  static SupportedLocale fromLocale(Locale locale) {
    for (final supported in SupportedLocale.values) {
      if (supported.locale.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return SupportedLocale.ja; // Default to Japanese
  }

  static Locale getDefaultLocale() {
    final systemLocale = WidgetsBinding.instance.window.locale;
    return SupportedLocale.fromLocale(systemLocale).locale;
  }
}

/// Localization notifier that manages the current locale
class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier(this._prefs) : super(SupportedLocale.ja.locale) {
    _initializeLocale();
  }

  final SharedPreferences _prefs;
  static const _localeKey = 'selected_locale';

  /// Initialize locale from stored preference or system default
  Future<void> _initializeLocale() async {
    final storedLocale = _prefs.getString(_localeKey);
    if (storedLocale != null) {
      state = Locale.fromSubtags(
        languageCode: storedLocale.split('_')[0],
        countryCode: storedLocale.split('_').length > 1
            ? storedLocale.split('_')[1]
            : null,
      );
    } else {
      state = SupportedLocale.getDefaultLocale();
    }
  }

  /// Change locale and persist to preferences
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final localeString =
        '${locale.languageCode}${locale.countryCode != null ? '_${locale.countryCode}' : ''}';
    await _prefs.setString(_localeKey, localeString);
  }

  /// Change locale by SupportedLocale enum
  Future<void> setLocaleFromEnum(SupportedLocale locale) async {
    await setLocale(locale.locale);
  }

  /// Get current supported locale
  SupportedLocale get currentLocale {
    return SupportedLocale.fromLocale(state);
  }

  /// Get list of all supported locales
  static List<Locale> get supportedLocales {
    return SupportedLocale.values.map((e) => e.locale).toList();
  }

  /// Get list of all supported locales with display names
  static List<SupportedLocale> get supportedLocalesWithNames {
    return SupportedLocale.values;
  }
}

/// FutureProvider to initialize SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// StateNotifierProvider for localization
final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.when(
    data: (prefs) => LocalizationNotifier(prefs),
    loading: () => LocalizationNotifier(
      SharedPreferences.getInstance() as SharedPreferences,
    ),
    error: (err, stack) => LocalizationNotifier(
      SharedPreferences.getInstance() as SharedPreferences,
    ),
  );
});

/// Provider to get current SupportedLocale
final currentSupportedLocaleProvider = Provider<SupportedLocale>((ref) {
  final locale = ref.watch(localizationProvider);
  return SupportedLocale.fromLocale(locale);
});
