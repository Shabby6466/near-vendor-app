import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/data_models/review.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/time_formatter.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/view/add_edit_review_screen.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/view/review_detail_screen.dart';
import 'package:nearvendorapp/views/widgets/rating_bar_widget.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final Shop shop;
  final VoidCallback? onDeleted;
  final VoidCallback? onEdited;

  const ReviewCard({
    super.key,
    required this.review,
    required this.shop,
    this.onDeleted,
    this.onEdited,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwnReview = review.userId == AppData().currentUser?.id;

    return GestureDetector(
      onTap: () {
        AppNavigator.push(
          context,
          ReviewDetailScreen(review: review, shopId: shop.id ?? ''),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isOwnReview
              ? theme.primaryColor.withValues(alpha: 0.02)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOwnReview
                ? theme.primaryColor.withValues(alpha: 0.25)
                : theme.dividerColor.withValues(alpha: 0.05),
            width: isOwnReview ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage:
                      review.userPhotoUrl != null &&
                          review.userPhotoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(review.userPhotoUrl!)
                      : null,
                  child:
                      review.userPhotoUrl == null ||
                          review.userPhotoUrl!.isEmpty
                      ? Text(
                          (review.userName ?? '?')[0].toUpperCase(),
                          style: TextStyle(color: theme.primaryColor),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.userName ?? 'Anonymous',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isOwnReview) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'You',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ] else if (review.userId == shop.vendorId) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Owner',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          RatingBarWidget.display(
                            rating: (review.rating ?? 0).toDouble(),
                            itemSize: 13,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            review.isEdited == true
                                ? 'Edited · ${TimeFormatter.timeAgo(review.updatedAt)}'
                                : TimeFormatter.timeAgo(review.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  itemBuilder: (context) => [
                    if (isOwnReview) ...[
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    if (!isOwnReview)
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('Report'),
                      ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      AppNavigator.push(
                        context,
                        AddEditReviewScreen(shop: shop, existingReview: review),
                      ).then((_) {
                        onEdited?.call();
                      });
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context);
                    } else if (value == 'report') {
                      _showReportDialog(context);
                    }
                  },
                ),
              ],
            ),
            if (review.text != null && review.text!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                review.text!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: review.images[index],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 70,
                        height: 70,
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if ((review.commentCount ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.commentCount} comment${review.commentCount! > 1 ? 's' : ''}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AppNavigator.pop(ctx);
              onDeleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    // Delegate to the review detail screen's report flow
    AppNavigator.push(
      context,
      ReviewDetailScreen(
        review: review,
        shopId: shop.id ?? '',
        autoReport: true,
      ),
    );
  }
}
