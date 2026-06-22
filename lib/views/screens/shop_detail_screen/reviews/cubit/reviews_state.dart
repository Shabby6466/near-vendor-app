part of 'reviews_cubit.dart';

sealed class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

final class ReviewsInitial extends ReviewsState {}

final class ReviewsLoading extends ReviewsState {}

final class ReviewsLoaded extends ReviewsState {
  final List<Review> reviews;
  final ReviewStats? stats;
  final ReviewSort sort;
  final bool hasMore;
  final bool hasUserReview;

  const ReviewsLoaded({
    required this.reviews,
    required this.stats,
    required this.sort,
    required this.hasMore,
    required this.hasUserReview,
  });

  @override
  List<Object?> get props => [reviews, stats, sort, hasMore, hasUserReview];
}

final class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}
