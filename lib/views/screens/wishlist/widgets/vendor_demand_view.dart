import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/wishlist_model.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubits/vendor_demand_cubit.dart';
import 'package:nearvendorapp/views/widgets/animated_error_state.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:intl/intl.dart';

class VendorDemandView extends StatelessWidget {
  const VendorDemandView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<VendorDemandCubit, VendorDemandState>(
        builder: (context, state) {
          if (state is VendorDemandInitial || state is VendorDemandLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorName.primary.withValues(alpha: 0.1),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1500.ms)
                       .fade(begin: 1.0, end: 0.0, duration: 1500.ms),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorName.primary.withValues(alpha: 0.2),
                        ),
                        child: const Icon(Icons.radar_rounded, color: ColorName.primary, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Scanning local area for unmet demand...',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.grey),
                  ).animate().fadeIn(duration: 800.ms),
                ],
              ),
            );
          }

          if (state is VendorDemandError) {
            return AnimatedErrorState(
              message: state.message,
              onRetry: () {
                final sessionState = context.read<SessionCubit>().state;
                if (sessionState.latitude != null && sessionState.longitude != null) {
                  context.read<VendorDemandCubit>().exploreLocalDemand(
                    lat: sessionState.latitude!, 
                    lon: sessionState.longitude!
                  );
                }
              },
            );
          }

          if (state is VendorDemandLoaded) {
            if (state.demands.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            return RefreshIndicator(
              color: ColorName.primary,
              onRefresh: () async {
                final sessionState = context.read<SessionCubit>().state;
                if (sessionState.latitude != null && sessionState.longitude != null) {
                  context.read<VendorDemandCubit>().exploreLocalDemand(
                    lat: sessionState.latitude!, 
                    lon: sessionState.longitude!
                  );
                }
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 120),
                itemCount: state.demands.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildDemandCard(context, state.demands[index], index, isDark);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDemandCard(BuildContext context, WishlistItem wish, int index, bool isDark) {
    // Beautiful gradient backgrounds per card
    final gradients = [
      [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
      [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
      [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
      [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
    ];
    
    final darkGradients = [
      [const Color(0xFF1A237E).withValues(alpha: 0.3), const Color(0xFF0D47A1).withValues(alpha: 0.1)],
      [const Color(0xFF4A148C).withValues(alpha: 0.3), const Color(0xFF311B92).withValues(alpha: 0.1)],
      [const Color(0xFF1B5E20).withValues(alpha: 0.3), const Color(0xFF004D40).withValues(alpha: 0.1)],
      [const Color(0xFFE65100).withValues(alpha: 0.3), const Color(0xFFBF360C).withValues(alpha: 0.1)],
    ];

    final selectedGradient = isDark ? darkGradients[index % 4] : gradients[index % 4];
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: selectedGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white60,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up_rounded, 
                    color: isDark ? Colors.white : Colors.black87, 
                    size: 20
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wish.itemName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Requested ${wish.createdAt != null ? dateFormat.format(wish.createdAt!) : "Unknown time"}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'HOT',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          if (wish.description != null && wish.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                '"${wish.description!}"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            
          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Nearby User',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    // Currently no action beyond viewing the data
                  },
                  icon: const Icon(Icons.add_business_rounded, size: 18),
                  label: const Text('Add to Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: ColorName.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: ColorName.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 100).ms, curve: Curves.easeOutQuad).fadeIn();
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ColorName.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 80,
              color: ColorName.primary.withValues(alpha: 0.5),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2.seconds)
          .fadeIn(duration: 800.ms),
          const SizedBox(height: 32),
          Text(
            'All Needs Met!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms).fadeIn(),
          const SizedBox(height: 16),
          Text(
            'There are currently no unmet product\nrequests matching your categories nearby.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 100.ms).fadeIn(),
        ],
      ),
    );
  }
}
