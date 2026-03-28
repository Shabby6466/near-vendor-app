part of 'item_detail_cubit.dart';

sealed class ItemDetailState extends Equatable {
  const ItemDetailState();

  @override
  List<Object?> get props => [];
}

final class ItemDetailInitial extends ItemDetailState {}

final class ItemDetailLoading extends ItemDetailState {}

final class ItemDetailSuccess extends ItemDetailState {
  final Item item;
  const ItemDetailSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

final class ItemDetailFailure extends ItemDetailState {
  final String message;
  const ItemDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
