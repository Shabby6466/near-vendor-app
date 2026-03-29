part of 'user_wishlist_cubit.dart';

abstract class UserWishlistState extends Equatable {
  const UserWishlistState();

  @override
  List<Object> get props => [];
}

class UserWishlistInitial extends UserWishlistState {}

class UserWishlistLoading extends UserWishlistState {}

class UserWishlistLoaded extends UserWishlistState {
  final List<WishlistItem> wishlists;
  final bool hasMore;
  final bool isFetchingMore;

  const UserWishlistLoaded({
    required this.wishlists,
    this.hasMore = false,
    this.isFetchingMore = false,
  });

  UserWishlistLoaded copyWith({
    List<WishlistItem>? wishlists,
    bool? hasMore,
    bool? isFetchingMore,
  }) {
    return UserWishlistLoaded(
      wishlists: wishlists ?? this.wishlists,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object> get props => [wishlists, hasMore, isFetchingMore];
}

class UserWishlistError extends UserWishlistState {
  final String message;

  const UserWishlistError({required this.message});

  @override
  List<Object> get props => [message];
}
