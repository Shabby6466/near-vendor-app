import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/api_responses/review_response.dart';
import 'package:nearvendorapp/views/widgets/rating_bar_widget.dart';

class RatingSummaryWidget extends StatelessWidget {
  final ReviewStats? stats;
  final VoidCallback? onTap;

  const RatingSummaryWidget({super.key, required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = this.stats;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Average rating
            Column(
              children: [
                Text(
                  stats != null ? stats.averageRating.toStringAsFixed(1) : '—',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                RatingBarWidget.display(
                  rating: stats?.averageRating ?? 0,
                  itemSize: 14,
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats?.totalReviews ?? 0} reviews',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Distribution bars
            Expanded(
              child: Column(
                children: List.generate(5, (index) {
                  final star = 5 - index;
                  final count = stats?.starCounts[star] ?? 0;
                  final total = stats?.totalReviews ?? 0;
                  final fraction = total > 0 ? count / total : 0.0;
                  return _buildStarBar(theme, star, count, fraction);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarBar(ThemeData theme, int star, int count, double fraction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.amber.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
