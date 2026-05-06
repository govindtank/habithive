import 'package:shared_preferences/shared_preferences.dart';

/// StorageService — persists onboarding state, theme preference, and habit data
/// Uses SharedPreferences so state survives page refreshes on web.
class StorageService {
  static const String _keyOnboardingComplete = 'habithive_onboarding_complete';
  static const String _keyDarkMode = 'habithive_dark_mode';
  static const String _keyProfileJson = 'habithive_profile_json';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Onboarding ────────────────────────────────────────────────
  static bool get hasCompletedOnboarding =>
      _prefs?.getBool(_keyOnboardingComplete) ?? false;

  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_keyOnboardingComplete, value);
  }

  // ── Dark Mode ─────────────────────────────────────────────────
  static bool get isDarkMode => _prefs?.getBool(_keyDarkMode) ?? false;

  static Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool(_keyDarkMode, value);
  }

  // ── Profile JSON (for habit data persistence) ──────────────────
  static String? get profileJson => _prefs?.getString(_keyProfileJson);

  static Future<void> setProfileJson(String json) async {
    await _prefs?.setString(_keyProfileJson, json);
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
