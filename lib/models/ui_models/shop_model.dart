class ShopModel {
  final String id;
  final String name;
  final String image;
  final String category;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int? itemCount;
  final bool? isVerifiedBadge;
  final bool? isRecentlyActive;
  final double? distance;

  ShopModel({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.location,
    this.itemCount,
    this.isVerifiedBadge,
    this.isRecentlyActive,
    this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'category': category,
      'location': location,
      'itemCount': itemCount,
      'isVerifiedBadge': isVerifiedBadge,
      'isRecentlyActive': isRecentlyActive,
      'distance': distance,
    };
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      location: json['location']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      itemCount: json['itemCount'] as int?,
      isVerifiedBadge: json['isVerifiedBadge'] as bool?,
      isRecentlyActive: json['isRecentlyActive'] as bool?,
      distance: double.tryParse(json['distance']?.toString() ?? ''),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShopModel &&
        other.id == id &&
        other.name == name &&
        other.image == image &&
        other.category == category &&
        other.location == location &&
        other.itemCount == itemCount &&
        other.isVerifiedBadge == isVerifiedBadge &&
        other.isRecentlyActive == isRecentlyActive &&
        other.distance == distance;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      image.hashCode ^
      category.hashCode ^
      location.hashCode ^
      itemCount.hashCode ^
      isVerifiedBadge.hashCode ^
      isRecentlyActive.hashCode ^
      distance.hashCode;

  @override
  String toString() {
    return 'ShopModel(id: $id, name: $name, distance: $distance)';
  }
}
