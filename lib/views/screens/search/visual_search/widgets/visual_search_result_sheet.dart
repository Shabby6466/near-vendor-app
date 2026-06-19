import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/views/screens/search/visual_search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class VisualSearchResultSheet extends StatelessWidget {
  final ValueChanged<List<Product>> onGroupTap;
  final VoidCallback onTryAgain;
  final double radiusKm;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<double> onRadiusChangeEnd;

  const VisualSearchResultSheet({
    super.key,
    required this.onGroupTap,
    required this.onTryAgain,
    required this.radiusKm,
    required this.onRadiusChanged,
    required this.onRadiusChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Material(
          color: isDark
              ? const Color(0xFF1C1C23)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          elevation: 16,
          child: BlocBuilder<VisualSearchCubit, VisualSearchState>(
            builder: (context, state) {
              final isLoading =
                  state is VisualSearchLoading || state is VisualSearchInitial;
              final isFailure = state is VisualSearchFailure;
              final items = state is VisualSearchSuccess
                  ? state.results
                  : <Product>[];
              final groups = VisualSearchCubit.groupByProduct(items);

              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Drag handle
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Loading State
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Column(
                              children: [
                                LoadingAnimation(
                                  size: 32,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Looking for results...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        // Error / Empty State
                        else if (isFailure || items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 48,
                              horizontal: 24,
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isFailure
                                      ? state.message
                                      : "No results found",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: onTryAgain,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${groups.length} Results',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '${radiusKm.toStringAsFixed(0)} KM',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    activeTrackColor: Colors.blue,
                                    inactiveTrackColor: Colors.grey.withValues(
                                      alpha: 0.2,
                                    ),
                                    thumbColor: Colors.blue,
                                    overlayColor: Colors.blue.withValues(
                                      alpha: 0.1,
                                    ),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                  ),
                                  child: Slider(
                                    value: radiusKm,
                                    min: 1.0,
                                    max: 100.0,
                                    divisions: 49,
                                    onChanged: onRadiusChanged,
                                    onChangeEnd: onRadiusChangeEnd,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Results List
                  if (!isLoading && !isFailure && items.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = groups.entries.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GroupProductCard(
                              groupItems: entry.value,
                              onTap: () => onGroupTap(entry.value),
                              onTryAgain: onTryAgain,
                            ),
                          );
                        }, childCount: groups.length),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _GroupProductCard extends StatelessWidget {
  final List<Product> groupItems;
  final VoidCallback onTap;
  final VoidCallback onTryAgain;

  const _GroupProductCard({
    required this.groupItems,
    required this.onTap,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final firstItem = groupItems.first;
    final maxScore = groupItems.fold<double>(
      0.0,
      (max, p) => (p.visualScore ?? 0) > max ? (p.visualScore ?? 0) : max,
    );
    final minPrice = groupItems.fold<double>(
      double.infinity,
      (min, p) => p.price < min ? p.price : min,
    );
    final shopCount = groupItems.length;

    final matchLabel = _resolveMatchLabel(maxScore);
    final labelColor = _matchLabelColor(maxScore);
    final matchPercentage = (maxScore * 100).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Match label row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                matchLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$matchPercentage%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Card
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: firstItem.displayImageUrl ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Starting from RS ${minPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1EC091),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            shopCount == 1
                                ? '1 shop nearby'
                                : '$shopCount shops nearby',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _resolveMatchLabel(double score) {
    if (score >= 0.80) return 'STRONG MATCH';
    if (score >= 0.60) return 'GOOD MATCH';
    if (score >= 0.40) return 'POSSIBLE MATCH';
    return 'WEAK MATCH';
  }

  Color _matchLabelColor(double score) {
    if (score >= 0.80) return const Color(0xFF004AAD);
    if (score >= 0.60) return const Color(0xFF1EC091);
    if (score >= 0.40) return Colors.amber.shade700;
    return Colors.orange;
  }
}
