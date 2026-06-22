part of 'review_detail_cubit.dart';

sealed class ReviewDetailState extends Equatable {
  const ReviewDetailState();

  @override
  List<Object?> get props => [];
}

final class ReviewDetailInitial extends ReviewDetailState {}

final class ReviewDetailLoading extends ReviewDetailState {}

final class ReviewDetailLoaded extends ReviewDetailState {
  final List<Comment> comments;
  final bool hasMore;
  final bool isSubmitting;

  const ReviewDetailLoaded({
    required this.comments,
    required this.hasMore,
    this.isSubmitting = false,
  });

  ReviewDetailLoaded copyWith({
    List<Comment>? comments,
    bool? hasMore,
    bool? isSubmitting,
  }) {
    return ReviewDetailLoaded(
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [comments, hasMore, isSubmitting];
}

final class ReviewDetailError extends ReviewDetailState {
  final String message;

  const ReviewDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
