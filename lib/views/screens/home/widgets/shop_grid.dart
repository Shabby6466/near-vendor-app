import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';

class ShopGrid extends StatelessWidget {
  const ShopGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        if (state is HomeScreenLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeScreenFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error: ${state.message}'),
            ),
          );
        }

        if (state is HomeScreenSuccess) {
          final shops = state.shops;
          if (shops.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No vendors found in this category'),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.only(
              left: AppSpacing.mediumHorizontalSpacing(context),
              right: AppSpacing.mediumHorizontalSpacing(context),
              top: 16,
              bottom: AppSpacing.screenHeight(context) * 0.1 + 24,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return ShopCard(shop: shop);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class ShopCard extends StatelessWidget {
  final ShopModel shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                shop.image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: ColorName.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.store, color: ColorName.primary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Assets.icons.locationMarker.svg(),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shop.location ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ColorName.primary.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
