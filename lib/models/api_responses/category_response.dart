import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';

class CategoryListResponse extends BaseApiResponse {
  final List<CategoryModel> categories;

  CategoryListResponse({
    super.statusCode,
    super.message,
    this.categories = const [],
  });

  CategoryListResponse.fromJson(dynamic json)
    : categories = json is Map
          ? apiResponseDataList(json)
                .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
      super.fromJson(json);
}
