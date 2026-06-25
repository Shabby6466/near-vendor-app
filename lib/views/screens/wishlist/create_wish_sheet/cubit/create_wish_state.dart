part of 'create_wish_cubit.dart';

sealed class CreateWishState extends Equatable {
  const CreateWishState();

  @override
  List<Object?> get props => [];
}

final class CreateWishInitial extends CreateWishState {}

final class CreateWishCategoriesLoaded extends CreateWishState {}

final class CreateWishSubmitting extends CreateWishState {}

final class CreateWishSuccess extends CreateWishState {}

final class CreateWishFailure extends CreateWishState {
  final String message;

  const CreateWishFailure(this.message);

  @override
  List<Object> get props => [message];
}
