class CreateOrderInput {
  final String vendorId;
  final String shopId;
  final List<OrderItemInput> items;
  final String shippingAddress;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final double shippingFee;
  final double? discount;
  final String? couponCode;
  final String? notes;

  CreateOrderInput({
    required this.vendorId,
    required this.shopId,
    required this.items,
    required this.shippingAddress,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.shippingFee = 0.0,
    this.discount,
    this.couponCode,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'vendorId': vendorId,
      'shopId': shopId,
      'items': items.map((e) => e.toJson()).toList(),
      'shippingAddress': shippingAddress,
      'shippingFee': shippingFee,
    };
    if (customerName != null) data['customerName'] = customerName;
    if (customerPhone != null) data['customerPhone'] = customerPhone;
    if (customerEmail != null) data['customerEmail'] = customerEmail;
    if (discount != null) data['discount'] = discount;
    if (couponCode != null) data['couponCode'] = couponCode;
    if (notes != null) data['notes'] = notes;
    return data;
  }
}

class OrderItemInput {
  final String itemId;
  final int quantity;
  final Map<String, dynamic>? extras;

  OrderItemInput({required this.itemId, required this.quantity, this.extras});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'itemId': itemId, 'quantity': quantity};
    if (extras != null) data['extras'] = extras;
    return data;
  }
}

class UpdateOrderInput {
  final String? status;
  final String? shippingAddress;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final double? shippingFee;
  final double? discount;
  final String? couponCode;
  final String? notes;

  UpdateOrderInput({
    this.status,
    this.shippingAddress,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.shippingFee,
    this.discount,
    this.couponCode,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (shippingAddress != null) data['shippingAddress'] = shippingAddress;
    if (customerName != null) data['customerName'] = customerName;
    if (customerPhone != null) data['customerPhone'] = customerPhone;
    if (customerEmail != null) data['customerEmail'] = customerEmail;
    if (shippingFee != null) data['shippingFee'] = shippingFee;
    if (discount != null) data['discount'] = discount;
    if (couponCode != null) data['couponCode'] = couponCode;
    if (notes != null) data['notes'] = notes;
    return data;
  }
}
