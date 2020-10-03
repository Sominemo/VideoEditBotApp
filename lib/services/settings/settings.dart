import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static SharedPreferences prefs;

  static Future<SharedPreferences> init() async {
    prefs ??= await SharedPreferences.getInstance();

    return prefs;
  }

  static bool getFlag(name, {bool def = false}) {
    return prefs.getBool(name) ?? def;
  }
}
