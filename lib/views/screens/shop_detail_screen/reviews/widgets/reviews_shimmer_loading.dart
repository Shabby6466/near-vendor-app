import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class ReviewsShimmerLoading extends StatelessWidget {
  const ReviewsShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Summary Skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Average Rating block
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 48,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const ShimmerEffect(borderRadius: 8),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: const ShimmerEffect(borderRadius: 4),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 60,
                        height: 10,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: const ShimmerEffect(borderRadius: 4),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Progress bars block
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                ),
                                child: const ShimmerEffect(borderRadius: 2),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: theme.primaryColor.withValues(alpha: 0.15),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 6,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(3)),
                                  ),
                                  child: const ShimmerEffect(borderRadius: 3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 15,
                                height: 10,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                ),
                                child: const ShimmerEffect(borderRadius: 2),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Sort Chips Skeleton
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final widths = [70.0, 80.0, 90.0, 75.0];
                  return Container(
                    width: widths[index % widths.length],
                    height: 36,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    child: const ShimmerEffect(borderRadius: 18),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Reviews List Skeleton
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const ShimmerEffect(borderRadius: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 12,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: const ShimmerEffect(borderRadius: 4),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 8,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 10,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: const ShimmerEffect(borderRadius: 4),
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
                      const SizedBox(height: 6),
                      Container(
                        width: 160,
                        height: 10,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: const ShimmerEffect(borderRadius: 4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
