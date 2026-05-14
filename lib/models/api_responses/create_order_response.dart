import 'package:nearvendorapp/models/data_models/order.dart';

class CreateOrderResponse {
  final bool success;
  final int statusCode;
  final String message;
  final Order? order;

  CreateOrderResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.order,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      order: json['data'] != null
          ? Order.fromJson(json['data'] as Map<String, dynamic>)
          : json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderListResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<Order> orders;

  OrderListResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.orders,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    List<Order> orders = [];

    if (json['data'] is List) {
      orders = (json['data'] as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['data'] is Map<String, dynamic>) {
      final dataObj = json['data'] as Map<String, dynamic>;
      if (dataObj['orders'] is List) {
        orders = (dataObj['orders'] as List)
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (json['orders'] is List) {
      orders = (json['orders'] as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return OrderListResponse(
      success: json['success'] as bool? ?? orders.isNotEmpty,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? 'Success',
      orders: orders,
    );
  }
}
