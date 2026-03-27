part of 'shop_form_cubit.dart';

sealed class ShopFormState extends Equatable {
  const ShopFormState();

  @override
  List<Object?> get props => [];
}

final class ShopFormInitial extends ShopFormState {}

final class ShopFormLoading extends ShopFormState {
  final String? message;
  const ShopFormLoading({this.message});

  @override
  List<Object?> get props => [message];
}

final class ShopFormSuccess extends ShopFormState {
  final Shop? shop;
  final bool isUpdate;
  const ShopFormSuccess({this.shop, this.isUpdate = false});

  @override
  List<Object?> get props => [shop, isUpdate];
}

final class ShopFormFailure extends ShopFormState {
  final String message;
  const ShopFormFailure(this.message);

  @override
  List<Object?> get props => [message];
}
