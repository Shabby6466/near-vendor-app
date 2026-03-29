class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) {
      return CategoryModel(id: json, name: json);
    }
    if (json is Map) {
      final id = (json['id'] ?? 
                  json['_id'] ?? 
                  json['uuid'] ?? 
                  json['categoryId'] ?? 
                  json['category_id'] ?? 
                  '').toString();
      final name = (json['name'] ?? 
                    json['categoryName'] ?? 
                    json['title'] ?? 
                    json['category_name'] ?? 
                    '').toString();
      
      return CategoryModel(
        id: id.isNotEmpty ? id : name,
        name: name.isNotEmpty ? name : id,
      );
    }
    return CategoryModel(id: '', name: 'Unknown');
  }

  static CategoryModel all() => CategoryModel(id: 'all', name: 'All Items');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
