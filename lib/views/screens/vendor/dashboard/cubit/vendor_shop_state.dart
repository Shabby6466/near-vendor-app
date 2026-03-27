part of 'vendor_shop_cubit.dart';

sealed class VendorShopState extends Equatable {
  const VendorShopState();

  @override
  List<Object> get props => [];
}

final class VendorShopInitial extends VendorShopState {}

final class VendorShopLoading extends VendorShopState {}

final class VendorShopSuccess extends VendorShopState {
  final List<Shop> shops;
  const VendorShopSuccess(this.shops);

  @override
  List<Object> get props => [shops];
}

final class VendorShopFailure extends VendorShopState {
  final String message;
  const VendorShopFailure(this.message);

  @override
  List<Object> get props => [message];
}
