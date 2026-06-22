import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class ProductDetailShimmerLoading extends StatelessWidget {
  const ProductDetailShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header Carousel Placeholder
          SizedBox(
            height: size.height * 0.55,
            width: double.infinity,
            child: const ShimmerEffect(borderRadius: 0),
          ),
          const SizedBox(height: 20),
          
          // Product Info Section Skeletons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 200,
                            height: 28,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                            ),
                            child: const ShimmerEffect(borderRadius: 4),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 16,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                            ),
                            child: const ShimmerEffect(borderRadius: 4),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 28,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: const ShimmerEffect(borderRadius: 4),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Description block Skeletons
                Container(
                  width: 120,
                  height: 18,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: const ShimmerEffect(borderRadius: 4),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 12,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: const ShimmerEffect(borderRadius: 4),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: const ShimmerEffect(borderRadius: 4),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 220,
                  height: 12,
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
