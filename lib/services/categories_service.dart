import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class CategoriesService {
  static Future<List<String>> getCategoriesNames() async {
    final response = await Server.get(ApiConstants.getCategoriesNames);
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => e.toString()).toList();
    } else {
      throw 'Failed to fetch categories';
    }
  }
}
