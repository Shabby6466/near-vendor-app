import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopListLoaded extends ShopState {
  final List<Shop> shops;
  const ShopListLoaded(this.shops);

  @override
  List<Object?> get props => [shops];
}

class ShopActionSuccess extends ShopState {
  final String message;
  const ShopActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ShopFailure extends ShopState {
  final String error;
  const ShopFailure(this.error);

  @override
  List<Object?> get props => [error];
}
