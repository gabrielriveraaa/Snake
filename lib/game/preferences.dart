import 'package:shared_preferences/shared_preferences.dart';

class GamePrefs {
  static const _kHighScore = 'high_score';
  static const _kSoundEnabled = 'sound_enabled';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kHighScore) ?? 0;
  }

  static Future<void> setHighScore(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHighScore, value);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSoundEnabled) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundEnabled, value);
  }
}
