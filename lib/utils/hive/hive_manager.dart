import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:nearvendorapp/utils/constants/hive_keys.dart';

class HiveManager {
  HiveManager._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox(HiveKeys.currentUserBox);
    _initialized = true;
  }

  static Box get currentUserBox => Hive.box(HiveKeys.currentUserBox);


  static void onLogout() {
    currentUserBox.clear();
  }

}