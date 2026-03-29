import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class CategoriesService {
  static List<CategoryModel>? _cachedCategories;

  static Future<List<CategoryModel>> getCategories() async {
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    final response = await Server.get(ApiConstants.getCategoriesNames);
    if (response.statusCode == 200) {
      final dynamic data = response.data;
      List<CategoryModel> categories = [];
      
      if (data is List) {
        categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final listData = (data['data'] as List<dynamic>?) ?? 
                        (data['categories'] as List<dynamic>?);
        if (listData != null) {
          categories = listData.map((e) => CategoryModel.fromJson(e)).toList();
        }
      }
      
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
