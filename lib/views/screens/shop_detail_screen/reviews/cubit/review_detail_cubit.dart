import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/comment.dart';
import 'package:nearvendorapp/services/review_services.dart';

part 'review_detail_state.dart';

class ReviewDetailCubit extends Cubit<ReviewDetailState> {
  final ReviewServices _reviewServices = ReviewServices();

  ReviewDetailCubit() : super(ReviewDetailInitial());

  String? _reviewId;
  final List<Comment> _comments = [];
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> loadComments(String? reviewId) async {
    if (reviewId == null) return;

    _reviewId = reviewId;
    _comments.clear();
    _currentPage = 1;
    _hasMore = true;
    emit(ReviewDetailLoading());

    try {
      final response = await _reviewServices.getComments(reviewId);
      if (response.isSuccess) {
        _comments.addAll(response.comments);
        _hasMore = _comments.length < (response.total ?? _comments.length);
        emit(
          ReviewDetailLoaded(
            comments: List.unmodifiable(_comments),
            hasMore: _hasMore,
          ),
        );
      } else {
        emit(ReviewDetailError(response.message ?? 'Failed to load comments'));
      }
    } catch (e) {
      emit(ReviewDetailError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_reviewId == null || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _currentPage++;

    try {
      final response = await _reviewServices.getComments(
        _reviewId!,
        page: _currentPage,
      );
      if (response.isSuccess) {
        _comments.addAll(response.comments);
        _hasMore = _comments.length < (response.total ?? _comments.length);
        emit(
          ReviewDetailLoaded(
            comments: List.unmodifiable(_comments),
            hasMore: _hasMore,
          ),
        );
      }
    } catch (_) {
      // Ignore pagination errors
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<bool> addComment({
    required String text,
    List<File> images = const [],
  }) async {
    if (_reviewId == null) return false;
    if (state is ReviewDetailLoaded) {
      emit((state as ReviewDetailLoaded).copyWith(isSubmitting: true));
    }
    final response = await _reviewServices.addComment(
      reviewId: _reviewId!,
      text: text,
      images: images,
    );
    if (response.isSuccess) {
      await loadComments(_reviewId);
      return true;
    }
    if (state is ReviewDetailLoaded) {
      emit((state as ReviewDetailLoaded).copyWith(isSubmitting: false));
    }
    return false;
  }

  Future<bool> updateComment({
    required String commentId,
    required String text,
    List<File> newImages = const [],
    List<String> existingImageUrls = const [],
  }) async {
    final response = await _reviewServices.updateComment(
      commentId: commentId,
      text: text,
      newImages: newImages,
      existingImageUrls: existingImageUrls,
    );
    if (response.isSuccess && _reviewId != null) {
      await loadComments(_reviewId);
      return true;
    }
    return false;
  }

  Future<void> deleteComment(String commentId) async {
    final response = await _reviewServices.deleteComment(commentId);
    if (response.isSuccess) {
      _comments.removeWhere((c) => c.id == commentId);
      emit(
        ReviewDetailLoaded(
          comments: List.unmodifiable(_comments),
          hasMore: _hasMore,
        ),
      );
    }
  }
}
