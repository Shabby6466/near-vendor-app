import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/comment.dart';
import 'package:nearvendorapp/models/data_models/review.dart';

class ReviewListResponse extends BaseApiResponse {
  final List<Review> reviews;
  final int? total;

  ReviewListResponse({
    super.statusCode,
    super.message,
    required this.reviews,
    this.total,
  });

  factory ReviewListResponse.fromJson(dynamic json) {
    if (json is Map) {
      final data = apiResponseData(json);
      List<dynamic>? itemsData;
      if (data is Map) {
        itemsData = data['items'] as List<dynamic>?;
      } else if (data is List) {
        itemsData = data;
      }
      itemsData ??= json['items'] as List<dynamic>?;

      return ReviewListResponse(
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? '',
        reviews: itemsData
                ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        total: data is Map
            ? (data['total'] as num?)?.toInt()
            : (json['total'] as num?)?.toInt(),
      );
    }
    return ReviewListResponse(
      statusCode: 500,
      message: 'Unexpected response format',
      reviews: const [],
    );
  }
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> starCounts;

  const ReviewStats({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.starCounts = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['starCounts'] as Map<String, dynamic>?;
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    if (rawCounts != null) {
      rawCounts.forEach((key, value) {
        final star = int.tryParse(key);
        if (star != null && star >= 1 && star <= 5) {
          counts[star] = (value as num?)?.toInt() ?? 0;
        }
      });
    }
    return ReviewStats(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      starCounts: counts,
    );
  }
}

class ReviewStatsResponse extends BaseApiResponse {
  final ReviewStats? stats;

  ReviewStatsResponse({
    super.statusCode,
    super.message,
    this.stats,
  });

  factory ReviewStatsResponse.fromJson(dynamic json) {
    if (json is Map) {
      final data = apiResponseData(json);
      return ReviewStatsResponse(
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? '',
        stats: data is Map<String, dynamic>
            ? ReviewStats.fromJson(data)
            : null,
      );
    }
    return ReviewStatsResponse(
      statusCode: 500,
      message: 'Unexpected response format',
    );
  }
}

class CommentListResponse extends BaseApiResponse {
  final List<Comment> comments;
  final int? total;

  CommentListResponse({
    super.statusCode,
    super.message,
    required this.comments,
    this.total,
  });

  factory CommentListResponse.fromJson(dynamic json) {
    if (json is Map) {
      final data = apiResponseData(json);
      List<dynamic>? itemsData;
      if (data is Map) {
        itemsData = data['items'] as List<dynamic>?;
      } else if (data is List) {
        itemsData = data;
      }
      itemsData ??= json['items'] as List<dynamic>?;

      return CommentListResponse(
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? '',
        comments: itemsData
                ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        total: data is Map
            ? (data['total'] as num?)?.toInt()
            : (json['total'] as num?)?.toInt(),
      );
    }
    return CommentListResponse(
      statusCode: 500,
      message: 'Unexpected response format',
      comments: const [],
    );
  }
}
