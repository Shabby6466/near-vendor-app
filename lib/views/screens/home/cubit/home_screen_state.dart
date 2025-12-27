part of 'home_screen_cubit.dart';

sealed class HomeScreenState extends Equatable {
  const HomeScreenState();

  @override
  List<Object?> get props => [];
}

final class HomeScreenInitial extends HomeScreenState {}

final class HomeScreenLoading extends HomeScreenState {}

final class HomeScreenSuccess extends HomeScreenState {
  final List<ShopModel> shops;
  final String category;

  const HomeScreenSuccess({required this.shops, required this.category});

  @override
  List<Object?> get props => [shops, category];
}

final class HomeScreenFailure extends HomeScreenState {
  final String message;

  const HomeScreenFailure(this.message);

  @override
  List<Object?> get props => [message];
}
