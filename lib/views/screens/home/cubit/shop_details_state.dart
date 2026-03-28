part of 'shop_details_cubit.dart';

sealed class ShopDetailsState extends Equatable {
  const ShopDetailsState();

  @override
  List<Object?> get props => [];
}

final class ShopDetailsInitial extends ShopDetailsState {}

final class ShopDetailsLoading extends ShopDetailsState {}

final class ShopDetailsSuccess extends ShopDetailsState {
  final Shop shop;
  final List<Item> inventory;

  const ShopDetailsSuccess({required this.shop, required this.inventory});

  @override
  List<Object?> get props => [shop, inventory];
}

final class ShopDetailsFailure extends ShopDetailsState {
  final String message;

  const ShopDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
