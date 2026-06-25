part of 'blocked_shops_cubit.dart';

sealed class BlockedShopsState extends Equatable {
  const BlockedShopsState();

  @override
  List<Object?> get props => [];
}

final class BlockedShopsInitial extends BlockedShopsState {}

final class BlockedShopsLoading extends BlockedShopsState {}

final class BlockedShopsSuccess extends BlockedShopsState {
  final List<BlockedShop> shops;
  const BlockedShopsSuccess({required this.shops});

  @override
  List<Object?> get props => [shops];
}

final class BlockedShopsFailure extends BlockedShopsState {
  final String error;
  const BlockedShopsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
