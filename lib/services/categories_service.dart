import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class CategoriesService {
  static Future<List<CategoryModel>> getCategories() async {
    final response = await Server.get(ApiConstants.getCategoriesNames);
    if (response.statusCode == 200) {
      final dynamic data = response.data;
      
      if (data is List) {
        return data.map((e) => CategoryModel.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final listData = (data['data'] as List<dynamic>?) ?? 
                        (data['categories'] as List<dynamic>?);
        if (listData != null) {
          return listData.map((e) => CategoryModel.fromJson(e)).toList();
        }
      }
      return [];
    } else {
      throw 'Failed to fetch categories';
    }
  }
}
