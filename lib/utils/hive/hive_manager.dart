import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:nearvendorapp/utils/constants/hive_keys.dart';

class HiveManager {
  HiveManager._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox(HiveKeys.currentUserBox);
    await Hive.openBox(HiveKeys.preferencesBox);
    _initialized = true;
  }

  static Box get currentUserBox => Hive.box(HiveKeys.currentUserBox);

  static Box get preferencesBox => Hive.box(HiveKeys.preferencesBox);

}
