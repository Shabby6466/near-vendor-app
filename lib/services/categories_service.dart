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

    try {
      final response = await Server.get(ApiConstants.getCategoriesNames);
      final categories = CategoryListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      _cachedCategories = categories;
      return categories;
    } catch (e) {
      return CategoryListResponse(success: false, message: e.toString());
    }
  }

  static void clearCache() {
    _cachedCategories = null;
  }
}
