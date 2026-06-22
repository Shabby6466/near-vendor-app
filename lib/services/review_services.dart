import 'dart:io';

import 'package:nearvendorapp/models/api_responses/review_response.dart';
import 'package:nearvendorapp/services/media_services.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

enum ReviewSort { latest, oldest, negative, positive }

class ReviewServices {
  Future<ReviewListResponse> getShopReviews(
    String shopId, {
    ReviewSort sort = ReviewSort.latest,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await Server.get(
        ApiConstants.shopReviews(shopId),
        queryParameters: {'sort': sort.name, 'page': page, 'limit': limit},
      );
      return ReviewListResponse.fromJson(response.data);
    } catch (e) {
      return ReviewListResponse(
        success: false,
        status: 500,
        message: e.toString(),
        reviews: const [],
      );
    }
  }

  Future<ReviewStatsResponse> getReviewStats(String shopId) async {
    try {
      final response = await Server.get(ApiConstants.shopReviewStats(shopId));
      return ReviewStatsResponse.fromJson(response.data);
    } catch (e) {
      return ReviewStatsResponse(
        success: false,
        status: 500,
        message: e.toString(),
      );
    }
  }

  Future<GenericApiResponse> createReview({
    required String shopId,
    required int rating,
    String? text,
    List<File> images = const [],
  }) async {
    try {
      final imageUrls = await _uploadImages(images);
      final response = await Server.post(
        ApiConstants.createReview,
        data: {
          'shopId': shopId,
          'rating': rating,
          if (text != null && text.isNotEmpty) 'text': text,
          if (imageUrls.isNotEmpty) 'images': imageUrls,
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> updateReview({
    required String reviewId,
    int? rating,
    String? text,
    List<File> newImages = const [],
    List<String> existingImageUrls = const [],
  }) async {
    try {
      final uploadedUrls = await _uploadImages(newImages);
      final allImages = [...existingImageUrls, ...uploadedUrls];
      final response = await Server.patch(
        ApiConstants.reviewById(reviewId),
        data: {
          if (rating != null) 'rating': rating,
          if (text != null) 'text': text,
          'images': allImages,
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> deleteReview(String reviewId) async {
    try {
      final response = await Server.delete(ApiConstants.reviewById(reviewId));
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> reportReview({
    required String reviewId,
    required String reason,
    String? additionalDetails,
  }) async {
    try {
      final response = await Server.post(
        ApiConstants.reportReview(reviewId),
        data: {
          'reason': reason,
          if (additionalDetails != null) 'additionalDetails': additionalDetails,
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<CommentListResponse> getComments(
    String reviewId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await Server.get(
        ApiConstants.reviewComments(reviewId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return CommentListResponse.fromJson(response.data);
    } catch (e) {
      return CommentListResponse(
        success: false,
        status: 500,
        message: e.toString(),
        comments: const [],
      );
    }
  }

  Future<GenericApiResponse> addComment({
    required String reviewId,
    required String text,
    List<File> images = const [],
  }) async {
    try {
      final imageUrls = await _uploadImages(images);
      final response = await Server.post(
        ApiConstants.reviewComments(reviewId),
        data: {'text': text, if (imageUrls.isNotEmpty) 'images': imageUrls},
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> updateComment({
    required String commentId,
    required String text,
    List<File> newImages = const [],
    List<String> existingImageUrls = const [],
  }) async {
    try {
      final uploadedUrls = await _uploadImages(newImages);
      final allImages = [...existingImageUrls, ...uploadedUrls];
      final response = await Server.patch(
        ApiConstants.commentById(commentId),
        data: {'text': text, 'images': allImages},
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> deleteComment(String commentId) async {
    try {
      final response = await Server.delete(ApiConstants.commentById(commentId));
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> reportComment({
    required String commentId,
    required String reason,
    String? additionalDetails,
  }) async {
    try {
      final response = await Server.post(
        ApiConstants.reportComment(commentId),
        data: {
          'reason': reason,
          if (additionalDetails != null) 'additionalDetails': additionalDetails,
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  /// Silently toggles review comment notifications (no loading state in UI).
  Future<void> toggleReviewNotifications(bool enabled) async {
    try {
      await Server.patch(
        ApiConstants.userReviewNotifications,
        data: {'enabled': enabled},
      );
    } catch (_) {
      // Silent — UI updates optimistically
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    final urls = <String>[];
    for (final image in images) {
      final response = await MediaServices.uploadImage(image);
      if (response.url != null) {
        urls.add(response.url!);
      }
    }
    return urls;
  }
}
