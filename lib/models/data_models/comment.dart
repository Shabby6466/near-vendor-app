import 'package:equatable/equatable.dart';

enum CommentAuthorType { user, vendor }

class Comment extends Equatable {
  final String? id;
  final String? reviewId;
  final String? authorId;
  final String? authorName;
  final String? authorPhotoUrl;
  final CommentAuthorType? authorType;
  final String? text;
  final List<String> images;
  final bool? isEdited;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Comment({
    this.id,
    this.reviewId,
    this.authorId,
    this.authorName,
    this.authorPhotoUrl,
    this.authorType,
    this.text,
    this.images = const [],
    this.isEdited,
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String?,
      reviewId: json['reviewId'] as String?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      authorType: json['authorType'] == 'VENDOR'
          ? CommentAuthorType.vendor
          : CommentAuthorType.user,
      text: json['text'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isEdited: json['isEdited'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        reviewId,
        authorId,
        authorName,
        authorPhotoUrl,
        authorType,
        text,
        images,
        isEdited,
        createdAt,
        updatedAt,
      ];
}
