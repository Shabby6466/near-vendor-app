part of 'product_detail_cubit.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailInitial extends ProductDetailState {}

final class ProductDetailLoading extends ProductDetailState {}

final class ProductDetailSuccess extends ProductDetailState {
  final Product item;
  final Shop? shop;

  const ProductDetailSuccess({required this.item, this.shop});

  @override
  List<Object?> get props => [item, shop];
}

final class ProductDetailFailure extends ProductDetailState {
  final String message;

  const ProductDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
