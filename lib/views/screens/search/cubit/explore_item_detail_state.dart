part of 'explore_item_detail_cubit.dart';

sealed class ExploreItemDetailState extends Equatable {
  const ExploreItemDetailState();

  @override
  List<Object?> get props => [];
}

final class ExploreItemDetailInitial extends ExploreItemDetailState {}

final class ExploreItemDetailLoading extends ExploreItemDetailState {}

final class ExploreItemDetailSuccess extends ExploreItemDetailState {
  final Item item;
  final Shop? shop;

  const ExploreItemDetailSuccess({required this.item, this.shop});

  @override
  List<Object?> get props => [item, shop];
}

final class ExploreItemDetailFailure extends ExploreItemDetailState {
  final String message;

  const ExploreItemDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
