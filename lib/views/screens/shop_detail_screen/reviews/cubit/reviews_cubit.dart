import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_responses/review_response.dart';
import 'package:nearvendorapp/models/data_models/review.dart';
import 'package:nearvendorapp/services/review_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewServices _reviewServices = ReviewServices();

  ReviewsCubit() : super(ReviewsInitial());

  String? _shopId;
  ReviewSort _currentSort = ReviewSort.latest;
  final List<Review> _reviews = [];
  ReviewStats? _stats;
  int _currentPage = 1;
  int? _total;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _hasUserReview = false;

  Future<void> loadReviews(
    String shopId, {
    ReviewSort? sort,
    bool? initialHasUserReview,
  }) async {
    _shopId = shopId;
    if (sort != null) _currentSort = sort;
    if (initialHasUserReview != null) {
      _hasUserReview = initialHasUserReview;
    }
    _reviews.clear();
    _currentPage = 1;
    _hasMore = true;
    emit(ReviewsLoading());

    try {
      final results = await Future.wait([
        _reviewServices.getReviewStats(shopId),
        _reviewServices.getShopReviews(shopId, sort: _currentSort),
      ]);

      final statsResponse = results[0] as ReviewStatsResponse;
      final reviewsResponse = results[1] as ReviewListResponse;

      if (statsResponse.isSuccess) _stats = statsResponse.stats;

      if (reviewsResponse.isSuccess) {
        _reviews.addAll(reviewsResponse.reviews);
        _total = reviewsResponse.total;
        _hasMore = _reviews.length < (_total ?? reviewsResponse.reviews.length);

        final currentUserId = AppData().currentUser?.id;
        if (currentUserId != null) {
          _hasUserReview =
              _hasUserReview || _reviews.any((r) => r.userId == currentUserId);
        }

        emit(
          ReviewsLoaded(
            reviews: List.unmodifiable(_reviews),
            stats: _stats,
            sort: _currentSort,
            hasMore: _hasMore,
            hasUserReview: _hasUserReview,
          ),
        );
      } else {
        emit(ReviewsError(reviewsResponse.message ?? 'Failed to load reviews'));
      }
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  Future<void> changeSort(ReviewSort sort) async {
    if (_shopId != null) {
      await loadReviews(_shopId!, sort: sort);
    }
  }

  Future<void> loadMore() async {
    if (_shopId == null || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _currentPage++;

    try {
      final response = await _reviewServices.getShopReviews(
        _shopId!,
        sort: _currentSort,
        page: _currentPage,
      );
      if (response.isSuccess) {
        _reviews.addAll(response.reviews);
        _total = response.total;
        _hasMore = _reviews.length < (_total ?? _reviews.length);

        final currentUserId = AppData().currentUser?.id;
        if (currentUserId != null) {
          _hasUserReview =
              _hasUserReview || _reviews.any((r) => r.userId == currentUserId);
        }

        emit(
          ReviewsLoaded(
            reviews: List.unmodifiable(_reviews),
            stats: _stats,
            sort: _currentSort,
            hasMore: _hasMore,
            hasUserReview: _hasUserReview,
          ),
        );
      }
    } catch (_) {
      // Ignore pagination errors
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    final currentUserId = AppData().currentUser?.id;
    final isDeletingOwnReview = _reviews.any(
      (r) => r.id == reviewId && r.userId == currentUserId,
    );

    final response = await _reviewServices.deleteReview(reviewId);
    if (response.isSuccess) {
      _reviews.removeWhere((r) => r.id == reviewId);
      if (isDeletingOwnReview) {
        _hasUserReview = false;
      }
      // Refresh stats
      if (_shopId != null) {
        final statsResponse = await _reviewServices.getReviewStats(_shopId!);
        if (statsResponse.isSuccess) _stats = statsResponse.stats;
      }
      emit(
        ReviewsLoaded(
          reviews: List.unmodifiable(_reviews),
          stats: _stats,
          sort: _currentSort,
          hasMore: _hasMore,
          hasUserReview: _hasUserReview,
        ),
      );
    }
  }

  Future<void> refresh() async {
    if (_shopId != null) {
      await loadReviews(_shopId!, sort: _currentSort);
    }
  }
}
