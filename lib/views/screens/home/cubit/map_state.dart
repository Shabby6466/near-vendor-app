import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';

abstract class MapState extends Equatable {
  final double latitude;
  final double longitude;
  final double radius; // In meters
  final List<Shop> shops;
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;

  const MapState({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.shops,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        radius,
        shops,
        categories,
        selectedCategory,
      ];
}

class MapInitial extends MapState {
  MapInitial({
    required super.latitude,
    required super.longitude,
    super.radius = 5000,
    super.shops = const [],
    super.categories = const [],
    CategoryModel? selectedCategory,
  }) : super(selectedCategory: selectedCategory ?? CategoryModel.all());
}

class MapLoading extends MapState {
  const MapLoading({
    required super.latitude,
    required super.longitude,
    required super.radius,
    required super.shops,
    required super.categories,
    required super.selectedCategory,
  });
}

class MapSuccess extends MapState {
  const MapSuccess({
    required super.latitude,
    required super.longitude,
    required super.radius,
    required super.shops,
    required super.categories,
    required super.selectedCategory,
  });
}

class MapFailure extends MapState {
  final String message;
  const MapFailure({
    required super.latitude,
    required super.longitude,
    required super.radius,
    required super.shops,
    required super.categories,
    required super.selectedCategory,
    required this.message,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        radius,
        shops,
        categories,
        selectedCategory,
        message,
      ];
}
