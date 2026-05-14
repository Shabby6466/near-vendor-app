import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String vendorId;
  final String? shopId;
  final String status;
  final double total;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.vendorId,
    this.shopId,
    required this.status,
    required this.total,
    required this.createdAt,
    this.updatedAt,
  });

  Order copyWith({
    String? id,
    String? vendorId,
    String? shopId,
    String? status,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      shopId: shopId ?? this.shopId,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      shopId: json['shopId'] as String?,
      status: json['status'] as String? ?? 'pending',
      total: double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'shopId': shopId,
      'status': status,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    vendorId,
    shopId,
    status,
    total,
    createdAt,
    updatedAt,
  ];
}
