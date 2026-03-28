import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:nearvendorapp/utils/constants/hive_keys.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';

class SearchStorage {
  SearchStorage._();

  static Box get _userBox => HiveManager.currentUserBox;

  static const int _maxRecentSearches = 15;

  static Future<void> addRecentSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    try {
      List<String> searches = getRecentSearches();
      
      // Remove if already exists (to move it to the front)
      searches.removeWhere((element) => element.toLowerCase() == keyword.toLowerCase().trim());
      
      // Add to front
      searches.insert(0, keyword.trim());
      
      // Limit to 15
      if (searches.length > _maxRecentSearches) {
        searches = searches.sublist(0, _maxRecentSearches);
      }
      
      await _userBox.put(HiveKeys.recentSearchesKey, searches);
    } catch (e) {
      debugPrint('Error adding recent search: $e');
    }
  }

  static List<String> getRecentSearches() {
    try {
      final List? searches = _userBox.get(
        HiveKeys.recentSearchesKey,
        defaultValue: [],
      );
      if (searches != null) {
        return List<String>.from(searches);
      }
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
    }
    return [];
  }

  static Future<void> clearRecentSearches() async {
    try {
      await _userBox.delete(HiveKeys.recentSearchesKey);
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }
}
