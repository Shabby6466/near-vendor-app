part of 'home_screen_cubit.dart';

sealed class HomeScreenState extends Equatable {
  const HomeScreenState();

  @override
  List<Object?> get props => [];
}

final class HomeScreenInitial extends HomeScreenState {}

final class HomeScreenLoading extends HomeScreenState {
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;
  const HomeScreenLoading({required this.categories, required this.selectedCategory});

  @override
  List<Object?> get props => [categories, selectedCategory];
}

final class HomeScreenSuccess extends HomeScreenState {
  final List<ShopModel> shops;
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;
  final String? message;
  final bool isGlobalFallback;
  final String? rangeMessage;

  const HomeScreenSuccess({
    required this.shops,
    required this.categories,
    required this.selectedCategory,
    this.message,
    this.isGlobalFallback = false,
    this.rangeMessage,
  });

  @override
  List<Object?> get props => [
        shops,
        categories,
        selectedCategory,
        message,
        isGlobalFallback,
        rangeMessage,
      ];
}

final class HomeScreenFailure extends HomeScreenState {
  final String message;
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;

  const HomeScreenFailure(this.message, {required this.categories, required this.selectedCategory});

  @override
  List<Object?> get props => [message, categories, selectedCategory];
}
