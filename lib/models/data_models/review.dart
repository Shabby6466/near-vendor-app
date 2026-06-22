import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String? id;
  final String? shopId;
  final String? userId;
  final String? userName;
  final String? userPhotoUrl;
  final int? rating;
  final String? text;
  final List<String> images;
  final bool? isEdited;
  final int? commentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Review({
    this.id,
    this.shopId,
    this.userId,
    this.userName,
    this.userPhotoUrl,
    this.rating,
    this.text,
    this.images = const [],
    this.isEdited,
    this.commentCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String?,
      shopId: json['shopId'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse(json['rating']?.toString() ?? ''),
      text: json['text'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isEdited: json['isEdited'] as bool?,
      commentCount: json['commentCount'] is int
          ? json['commentCount'] as int
          : int.tryParse(json['commentCount']?.toString() ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'userId': userId,
      'rating': rating,
      'text': text,
      'images': images,
    };
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        userId,
        userName,
        userPhotoUrl,
        rating,
        text,
        images,
        isEdited,
        commentCount,
        createdAt,
        updatedAt,
      ];
}
