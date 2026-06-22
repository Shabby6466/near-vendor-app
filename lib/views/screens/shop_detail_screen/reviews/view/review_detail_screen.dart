import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/comment.dart';
import 'package:nearvendorapp/models/data_models/review.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/time_formatter.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/common/image_viewer_screen.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/cubit/review_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/widgets/comment_card.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/widgets/comment_input.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';
import 'package:nearvendorapp/views/widgets/rating_bar_widget.dart';
import 'package:nearvendorapp/views/widgets/safety_report_dialog.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class ReviewDetailScreen extends StatelessWidget {
  final Review review;
  final String shopId;
  final bool autoReport;

  const ReviewDetailScreen({
    super.key,
    required this.review,
    required this.shopId,
    this.autoReport = false,
  });

  void _showReportDialog(BuildContext context, String reviewId) {
    if (!AppData().isLoggedIn) {
      AppAlerts.showError(context, 'Please sign in to report');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => SafetyReportDialog(
        targetId: reviewId,
        targetType: 'REVIEW',
        targetName: 'Review',
      ),
    );
  }

  void _showCommentReportDialog(BuildContext context, Comment comment) {
    showDialog(
      context: context,
      builder: (ctx) => SafetyReportDialog(
        targetId: comment.id ?? '',
        targetType: 'COMMENT',
        targetName: 'Comment',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ReviewDetailCubit()..loadComments(review.id);
        if (autoReport) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showReportDialog(context, review.id ?? '');
          });
        }
        return cubit;
      },
      child: BlocBuilder<ReviewDetailCubit, ReviewDetailState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final isOwnReview = review.userId == AppData().currentUser?.id;
          final isSubmitting =
              state is ReviewDetailLoaded && state.isSubmitting;

          return LoadingScreenView(
            isLoading: isSubmitting,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Review'),
                actions: [
                  if (!isOwnReview)
                    IconButton(
                      icon: const Icon(Icons.flag_outlined),
                      onPressed: () =>
                          _showReportDialog(context, review.id ?? ''),
                    ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReviewHeader(context, theme),
                          if (review.text != null &&
                              review.text!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              review.text!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                          if (review.images.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildImageGallery(theme),
                          ],
                          const SizedBox(height: 24),
                          Divider(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Text(
                                'Comments',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (state is ReviewDetailLoading)
                            _buildCommentsShimmer(context)
                          else if (state is ReviewDetailError)
                            Text(
                              state.message,
                              style: TextStyle(color: theme.colorScheme.error),
                            )
                          else if (state is ReviewDetailLoaded) ...[
                            if (state.comments.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  'No comments yet. Be the first to comment.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.5),
                                  ),
                                ),
                              )
                            else
                              ...state.comments.map(
                                (comment) => CommentCard(
                                  comment: comment,
                                  onReport: () => _showCommentReportDialog(
                                    context,
                                    comment,
                                  ),
                                  onDelete: () => context
                                      .read<ReviewDetailCubit>()
                                      .deleteComment(comment.id ?? ''),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (AppData().isLoggedIn)
                    CommentInput(
                      isSubmitting: isSubmitting,
                      onSubmit: (text, images) async {
                        final success = await context
                            .read<ReviewDetailCubit>()
                            .addComment(text: text, images: images);
                        if (!success && context.mounted) {
                          AppAlerts.showError(context, 'Failed to add comment');
                        }
                        return success;
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (review.userPhotoUrl != null &&
                review.userPhotoUrl!.isNotEmpty) {
              AppNavigator.push(
                context,
                ImageViewerScreen(
                  imageUrls: [review.userPhotoUrl!],
                ),
              );
            }
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            backgroundImage:
                review.userPhotoUrl != null && review.userPhotoUrl!.isNotEmpty
                ? CachedNetworkImageProvider(review.userPhotoUrl!)
                : null,
            child: review.userPhotoUrl == null || review.userPhotoUrl!.isEmpty
                ? Text(
                    (review.userName ?? '?')[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                review.userName ?? 'Anonymous',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              RatingBarWidget.display(
                rating: (review.rating ?? 0).toDouble(),
              ),
              const SizedBox(height: 2),
              Text(
                review.isEdited == true
                    ? 'Edited · ${TimeFormatter.timeAgo(review.updatedAt)}'
                    : TimeFormatter.timeAgo(review.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(ThemeData theme) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            AppNavigator.push(
              context,
              ImageViewerScreen(
                imageUrls: review.images,
                initialIndex: index,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: review.images[index],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Container(
                width: 120,
                height: 120,
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsShimmer(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const ShimmerEffect(borderRadius: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 10,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: const ShimmerEffect(borderRadius: 4),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 40,
                      height: 8,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: const ShimmerEffect(borderRadius: 4),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 10,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: const ShimmerEffect(borderRadius: 4),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 140,
                  height: 10,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: const ShimmerEffect(borderRadius: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
