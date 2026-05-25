part of 'explore_screen_cubit.dart';

sealed class ExploreScreenState extends Equatable {
  const ExploreScreenState();

  @override
  List<Object?> get props => [];
}

final class ExploreScreenInitial extends ExploreScreenState {}

final class ExploreScreenLoading extends ExploreScreenState {
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;
  const ExploreScreenLoading({
    required this.categories,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [categories, selectedCategory];
}

final class ExploreScreenSuccess extends ExploreScreenState {
  final List<Shop> shops;
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;
  final String? message;
  final bool isGlobalFallback;
  final String? rangeMessage;

  const ExploreScreenSuccess({
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

final class ExploreScreenFailure extends ExploreScreenState {
  final String message;
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;

  const ExploreScreenFailure(
    this.message, {
    required this.categories,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [message, categories, selectedCategory];
}

final class ExploreScreenNoLocation extends ExploreScreenState {
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;
  final String message;

  const ExploreScreenNoLocation({
    required this.categories,
    required this.selectedCategory,
    this.message = 'Location not found. Please set it manually.',
  });

  @override
  List<Object?> get props => [categories, selectedCategory, message];
}
