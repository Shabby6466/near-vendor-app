import 'package:nearvendorapp/models/api_responses/category_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

final class CategoriesService {
  // Private constructor to prevent instantiation
  CategoriesService._();

  static CategoryListResponse? _cachedCategories;

  static Future<CategoryListResponse> getCategories() async {
    if (_cachedCategories != null && _cachedCategories!.categories.isNotEmpty) {
      return _cachedCategories!;
    }

    final response = await Server.get(ApiConstants.getCategoriesNames);
    if (response.statusCode == 200) {
      final categories = CategoryListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      _cachedCategories = categories;
      return categories;
    } else {
      throw 'Failed to fetch categories';
    }
  }

  static void clearCache() {
    _cachedCategories = null;
  }
}
