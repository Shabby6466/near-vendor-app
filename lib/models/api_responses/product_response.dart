import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';

class ProductResponse extends BaseApiResponse {
  final Product? product;

  ProductResponse({
    super.statusCode,
    super.message,
    this.product,
  });

  ProductResponse.fromJson(dynamic json)
    : product = json is Map ? _parseItem(json as Map<String, dynamic>) : null,
      super.fromJson(json);

  static Product? _parseItem(Map<String, dynamic> json) {
    final data = apiResponseData(json);
    final productJson = data is Map && data['product'] != null
        ? data['product']
        : data is Map && data['item'] != null
            ? data['item']
            : data;
    return productJson is Map<String, dynamic> ? Product.fromJson(productJson) : null;
  }
}

class PaginationMeta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  PaginationMeta({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProductListResponse extends BaseApiResponse {
  final List<Product> products;
  final PaginationMeta? meta;

  ProductListResponse({
    super.statusCode,
    super.message,
    required this.products,
    this.meta,
  });

  factory ProductListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ProductListResponse(
        statusCode: 200,
        message: 'Success',
        products: json
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    if (json is Map<String, dynamic>) {
      final dataObj = json['data'];
      List<dynamic>? productsList;
      Map<String, dynamic>? metaData;

      if (dataObj is List) {
        productsList = dataObj;
      } else if (dataObj is Map<String, dynamic>) {
        productsList = (dataObj['products'] ?? dataObj['items']) as List<dynamic>?;
        metaData = dataObj['meta'] as Map<String, dynamic>?;
      }

      productsList ??= apiResponseDataList(json);
      metaData ??= json['meta'] as Map<String, dynamic>?;

      return ProductListResponse(
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? 'Success',
        products: productsList
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: metaData != null ? PaginationMeta.fromJson(metaData) : null,
      );
    }

    return ProductListResponse(
      statusCode: 500,
      message: 'Unexpected response format',
      products: const [],
    );
  }
}
