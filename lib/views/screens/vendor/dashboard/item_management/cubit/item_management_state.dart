part of 'item_management_cubit.dart';

sealed class ItemManagementState extends Equatable {
  const ItemManagementState();

  @override
  List<Object?> get props => [];
}

final class ItemManagementInitial extends ItemManagementState {}

final class ItemManagementLoading extends ItemManagementState {}

final class ItemManagementSuccess extends ItemManagementState {
  final List<Item> items;
  const ItemManagementSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

final class ItemManagementFailure extends ItemManagementState {
  final String message;
  const ItemManagementFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ItemActionLoading extends ItemManagementState {}

final class ItemActionSuccess extends ItemManagementState {
  final String message;
  const ItemActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
