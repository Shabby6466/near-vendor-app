class ShopModel {
  String name;
  String image;
  String category;
  String? location;

  ShopModel({
    required this.name,
    required this.image,
    required this.category,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'category': category,
      'location': location,
    };
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      location: json['location']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShopModel &&
        other.name == name &&
        other.image == image &&
        other.category == category &&
        other.location == location;
  }

  @override
  int get hashCode =>
      name.hashCode ^ image.hashCode ^ category.hashCode ^ location.hashCode;

  @override
  String toString() {
    return 'ShopModel(name: $name, image: $image, category: $category, location: $location)';
  }
}
