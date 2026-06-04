import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/enums/stock_status.dart';

class Product extends Equatable {
  final String id;
  final String? productId; // cross-compatible with ShopProduct
  final String? shopId;
  final String? vendorId;
  final String name;
  final String? productName; // cross-compatible with ShopProduct
  final String description;
  final String? productDescription; // cross-compatible with ShopProduct
  final double price;
  final String unit;
  final int stockCount;
  final int? quantity; // cross-compatible with ShopProduct
  final List<String> imageUrls;
  final String? imageUrl; // cross-compatible with ShopProduct
  final StockStatus? stockStatus; // cross-compatible with ShopProduct
  final bool isAvailable;
  final bool? isActive; // cross-compatible with ShopProduct
  final double? discount;
  final Map<String, dynamic>? shop; // For portfolio results
  final int? count; // For performance results
  final double? distanceM;
  final double? visualScore;
  final String? matchLabel;
  final double? lat;
  final double? long;
  final int? volatilityFactor;
  final bool? isPossiblyLowStock;
  final DateTime? lastStockUpdatedAt;
  final String? categoryId;
  final String? categoryName;
  final String? barcode;

  const Product({
    required this.id,
    this.productId,
    this.shopId,
    this.vendorId,
    required this.name,
    this.productName,
    required this.description,
    this.productDescription,
    required this.price,
    required this.unit,
    required this.stockCount,
    this.quantity,
    this.imageUrls = const [],
    this.imageUrl,
    this.stockStatus,
    this.isAvailable = true,
    this.isActive,
    this.discount,
    this.shop,
    this.count,
    this.distanceM,
    this.visualScore,
    this.matchLabel,
    this.lat,
    this.long,
    this.volatilityFactor,
    this.isPossiblyLowStock,
    this.lastStockUpdatedAt,
    this.categoryId,
    this.categoryName,
    this.barcode,
  });

  /// Primary display image (first in the list, or null, or fallback to imageUrl)
  String? get displayImageUrl => imageUrls.isNotEmpty ? imageUrls.first : imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Support both new 'imageUrls' array and legacy 'imageUrl' string
    List<String> urls = [];
    if (json['imageUrls'] != null) {
      urls = List<String>.from(json['imageUrls'] as List);
    } else if (json['imageUrl'] != null &&
        (json['imageUrl'] as String).isNotEmpty) {
      urls = [json['imageUrl'] as String];
    }
    final firstImage = urls.isNotEmpty ? urls.first : (json['imageUrl'] as String?);

    // price comes as string/num from backend
    double parsedPrice = 0.0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    final int qty = json['stockCount'] as int? ?? json['quantity'] as int? ?? 0;
    final bool active = json['isAvailable'] as bool? ?? json['isActive'] as bool? ?? true;

    return Product(
      id: json['id'] as String? ?? json['productId'] as String? ?? '',
      productId: json['productId'] as String? ?? json['id'] as String?,
      shopId: json['shopId'] as String?,
      vendorId: json['vendorId'] as String?,
      name: json['name'] as String? ?? json['productName'] as String? ?? '',
      productName: json['productName'] as String? ?? json['name'] as String?,
      description: json['description'] as String? ?? json['productDescription'] as String? ?? '',
      productDescription: json['productDescription'] as String? ?? json['description'] as String?,
      price: parsedPrice,
      unit: json['unit'] as String? ?? '',
      stockCount: qty,
      quantity: qty,
      imageUrls: urls,
      imageUrl: firstImage,
      stockStatus: StockStatus.fromValue(json['stockStatus'] as String? ?? (active ? 'available' : 'out_of_stock')),
      isAvailable: active,
      isActive: active,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString())
          : null,
      shop: json['shop'] as Map<String, dynamic>?,
      count: json['count'] as int?,
      distanceM: double.tryParse(json['distance_m']?.toString() ?? json['distanceM']?.toString() ?? json['distance']?.toString() ?? ''),
      visualScore: double.tryParse(json['visualScore']?.toString() ?? ''),
      matchLabel: json['matchLabel'] as String?,
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      long: double.tryParse(json['long']?.toString() ?? ''),
      volatilityFactor: json['volatilityFactor'] as int?,
      isPossiblyLowStock: json['isPossiblyLowStock'] as bool? ?? ((json['volatilityFactor'] as int? ?? 1) > 3),
      lastStockUpdatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String? ??
          (json['category'] is Map
              ? (json['category'] as Map)['categoryName'] as String?
              : null),
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId ?? id,
      'shopId': shopId,
      'vendorId': vendorId,
      'name': name,
      'productName': productName ?? name,
      'description': description,
      'productDescription': productDescription ?? description,
      'price': price,
      'unit': unit,
      'stockCount': stockCount,
      'quantity': quantity ?? stockCount,
      'imageUrls': imageUrls,
      'imageUrl': imageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null),
      'stockStatus': stockStatus?.value,
      'isAvailable': isAvailable,
      'isActive': isActive ?? isAvailable,
      'discount': discount,
      'shop': shop,
      'count': count,
      'distanceM': distanceM,
      'visualScore': visualScore,
      'matchLabel': matchLabel,
      'lat': lat,
      'long': long,
      'volatilityFactor': volatilityFactor,
      'isPossiblyLowStock': isPossiblyLowStock,
      'updatedAt': lastStockUpdatedAt?.toIso8601String(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'barcode': barcode,
    };
  }

  Product copyWith({
    String? id,
    String? productId,
    String? shopId,
    String? vendorId,
    String? name,
    String? productName,
    String? description,
    String? productDescription,
    double? price,
    String? unit,
    int? stockCount,
    int? quantity,
    List<String>? imageUrls,
    String? imageUrl,
    StockStatus? stockStatus,
    bool? isAvailable,
    bool? isActive,
    double? discount,
    Map<String, dynamic>? shop,
    int? count,
    double? distanceM,
    double? visualScore,
    String? matchLabel,
    double? lat,
    double? long,
    int? volatilityFactor,
    bool? isPossiblyLowStock,
    DateTime? lastStockUpdatedAt,
    String? categoryId,
    String? categoryName,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      shopId: shopId ?? this.shopId,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      productDescription: productDescription ?? this.productDescription,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stockCount: stockCount ?? this.stockCount,
      quantity: quantity ?? this.quantity,
      imageUrls: imageUrls ?? this.imageUrls,
      imageUrl: imageUrl ?? this.imageUrl,
      stockStatus: stockStatus ?? this.stockStatus,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      discount: discount ?? this.discount,
      shop: shop ?? this.shop,
      count: count ?? this.count,
      distanceM: distanceM ?? this.distanceM,
      visualScore: visualScore ?? this.visualScore,
      matchLabel: matchLabel ?? this.matchLabel,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      volatilityFactor: volatilityFactor ?? this.volatilityFactor,
      isPossiblyLowStock: isPossiblyLowStock ?? this.isPossiblyLowStock,
      lastStockUpdatedAt: lastStockUpdatedAt ?? this.lastStockUpdatedAt,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      barcode: barcode ?? this.barcode,
    );
  }

  /// Toggles availability status
  Product toggleAvailability() {
    return copyWith(
      isAvailable: !isAvailable,
      isActive: !isAvailable,
      stockStatus: !isAvailable ? StockStatus.available : StockStatus.outOfStock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        shopId,
        vendorId,
        name,
        productName,
        description,
        productDescription,
        price,
        unit,
        stockCount,
        quantity,
        imageUrls,
        imageUrl,
        stockStatus,
        isAvailable,
        isActive,
        discount,
        shop,
        count,
        distanceM,
        visualScore,
        matchLabel,
        lat,
        long,
        volatilityFactor,
        isPossiblyLowStock,
        lastStockUpdatedAt,
        categoryId,
        categoryName,
        barcode,
      ];
}
