import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/review_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/cubit/reviews_cubit.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/view/add_edit_review_screen.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/widgets/rating_summary_widget.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/widgets/review_card.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/widgets/reviews_shimmer_loading.dart';
import 'package:nearvendorapp/views/widgets/animated_error_state.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class ReviewsScreen extends StatelessWidget {
  final Shop shop;

  const ReviewsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewsCubit()
        ..loadReviews(
          shop.id ?? '',
          initialHasUserReview: shop.userReview != null,
        ),
      child: Scaffold(
        appBar: AppBar(title: Text(shop.shopName ?? 'Reviews')),
        body: BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is ReviewsError) {
              AppAlerts.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is ReviewsLoading) {
              return const ReviewsShimmerLoading();
            }
            if (state is ReviewsError) {
              return AnimatedErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<ReviewsCubit>().loadReviews(shop.id ?? ''),
              );
            }
            if (state is ReviewsLoaded) {
              return _buildBody(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<ReviewsCubit, ReviewsState>(
          builder: (context, state) {
            if (state is ReviewsLoaded && state.hasUserReview) {
              return const SizedBox.shrink();
            }
            return _buildWriteReviewFab(context) ?? const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget? _buildWriteReviewFab(BuildContext context) {
    if (!AppData().isLoggedIn) return null;
    return FloatingActionButton.extended(
      onPressed: () {
        AppNavigator.push(context, AddEditReviewScreen(shop: shop)).then((_) {
          if (context.mounted) {
            return context.read<ReviewsCubit>().refresh();
          }
        });
      },
      icon: const Icon(Icons.rate_review_rounded),
      label: const Text('Write a Review'),
    );
  }

  Widget _buildBody(BuildContext context, ReviewsLoaded state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          context.read<ReviewsCubit>().loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingSummaryWidget(stats: state.stats),
                  const SizedBox(height: 16),
                  _buildSortChips(context, state.sort),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (state.reviews.isEmpty)
            _buildEmptyState(context)
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final review = state.reviews[index];
                  return ReviewCard(
                    review: review,
                    shop: shop,
                    onDeleted: () => _deleteReview(context, review.id ?? ''),
                    onEdited: () => context.read<ReviewsCubit>().refresh(),
                  );
                }, childCount: state.reviews.length),
              ),
            ),
          if (state.hasMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSortChips(BuildContext context, ReviewSort currentSort) {
    final theme = Theme.of(context);
    const options = ReviewSort.values;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sort = options[index];
          final isSelected = sort == currentSort;
          return GestureDetector(
            onTap: () => context.read<ReviewsCubit>().changeSort(sort),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.dividerColor.withValues(alpha: 0.15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _sortLabel(sort),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _sortLabel(ReviewSort sort) {
    switch (sort) {
      case ReviewSort.latest:
        return 'Latest';
      case ReviewSort.oldest:
        return 'Oldest';
      case ReviewSort.negative:
        return 'Negative';
      case ReviewSort.positive:
        return 'Positive';
    }
  }

  Future<void> _deleteReview(BuildContext context, String reviewId) async {
    if (!AppData().isLoggedIn) {
      AppNavigator.push(context, const LoginScreen());
      return;
    }
    await context.read<ReviewsCubit>().deleteReview(reviewId);
    if (context.mounted) {
      AppAlerts.showSuccess(context, 'Review deleted');
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                  size: 80,
                  color: theme.primaryColor,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2.seconds,
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  )
                  .shake(hz: 2, curve: Curves.easeInOut),
              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
              Text(
                'No Reviews Yet',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 12),
              Text(
                'Be the first to share your experience with this shop!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              SizedBox(height: AppSpacing.largeVerticalSpacing(context) * 1.5),
              AppElevatedButton(
                text: 'Write a Review',
                onPressed: () {
                  if (AppData().isLoggedIn) {
                    AppNavigator.push(
                      context,
                      AddEditReviewScreen(shop: shop),
                    ).then((_) {
                      if (context.mounted) {
                        context.read<ReviewsCubit>().refresh();
                      }
                    });
                  } else {
                    AppBottomSheet.showConfirmationBottomSheet(
                      context: context,
                      title: 'Sign In Required',
                      message: 'You need to sign in to add review to a shop.',
                      confirmButtonText: 'Sign In',
                      onConfirm: () {
                        AppNavigator.push(context, const LoginScreen());
                      },
                    );
                  }
                },
              ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
