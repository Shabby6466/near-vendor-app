import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';

class PortfolioSearchResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<Shop> shops;
  final List<Item> items;
  final PortfolioPagination? pagination;

  PortfolioSearchResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.shops,
    required this.items,
    this.pagination,
  });

  factory PortfolioSearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return PortfolioSearchResponse(
      success: json['success'] as bool? ?? (json['statusCode'] == 200),
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? 'Success',
      shops: (data?['shops'] as List?)?.map((e) => Shop.fromJson(e)).toList() ?? [],
      items: (data?['items'] as List?)?.map((e) => Item.fromJson(e)).toList() ?? [],
      pagination: data?['pagination'] != null 
          ? PortfolioPagination.fromJson(data!['pagination']) 
          : null,
    );
  }
}

class PortfolioPerformanceResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<Item> bestPerformers;
  final List<Item> poorPerformers;

  PortfolioPerformanceResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.bestPerformers,
    required this.poorPerformers,
  });

  factory PortfolioPerformanceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return PortfolioPerformanceResponse(
      success: json['success'] as bool? ?? (json['statusCode'] == 200),
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? 'Success',
      bestPerformers: (data?['bestPerformers'] as List?)?.map((e) => Item.fromJson(e)).toList() ?? [],
      poorPerformers: (data?['poorPerformers'] as List?)?.map((e) => Item.fromJson(e)).toList() ?? [],
    );
  }
}

class PortfolioPagination {
  final int page;
  final int limit;
  final int totalShops;
  final int totalItems;
  final int totalPageShops;
  final int totalPageItems;

  PortfolioPagination({
    required this.page,
    required this.limit,
    required this.totalShops,
    required this.totalItems,
    required this.totalPageShops,
    required this.totalPageItems,
  });

  factory PortfolioPagination.fromJson(Map<String, dynamic> json) {
    return PortfolioPagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalShops: json['totalShops'] as int? ?? 0,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPageShops: json['totalPageShops'] as int? ?? 0,
      totalPageItems: json['totalPageItems'] as int? ?? 0,
    );
  }
}
