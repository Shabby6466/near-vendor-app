part of 'shop_detail_cubit.dart';

sealed class ShopDetailState extends Equatable {
  const ShopDetailState();

  @override
  List<Object?> get props => [];
}

final class ShopDetailInitial extends ShopDetailState {}

final class ShopDetailLoading extends ShopDetailState {}

final class ShopDetailSuccess extends ShopDetailState {
  final Shop shop;
  final List<Product> inventory;

  const ShopDetailSuccess({required this.shop, required this.inventory});

  @override
  List<Object?> get props => [shop, inventory];
}

final class ShopDetailFailure extends ShopDetailState {
  final String message;

  const ShopDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
