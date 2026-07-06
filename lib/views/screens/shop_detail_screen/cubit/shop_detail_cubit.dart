import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/analytics/analytics_controller.dart';
import 'package:nearvendorapp/analytics/analytics_event.dart';
import 'package:nearvendorapp/models/api_responses/product_response.dart';
import 'package:nearvendorapp/models/api_responses/review_response.dart';
import 'package:nearvendorapp/models/api_responses/shop_response.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/product_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'shop_detail_state.dart';

class ShopDetailCubit extends Cubit<ShopDetailState> {
  final ShopServices _shopServices = ShopServices();
  final ProductServices _productServices = ProductServices();

  ShopDetailCubit() : super(ShopDetailInitial());

  Future<void> loadShopData(String shopId, {Shop? initialShop}) async {
    if (initialShop != null) {
      emit(
        ShopDetailSuccess(
          shop: initialShop,
          inventory: const [],
          reviewStats: initialShop.reviewStats, // May be null initially
          isLoadingInventory: true,
        ),
      );
    } else {
      emit(ShopDetailLoading());
    }

    try {
      try {
        final position = await Geolocator.getCurrentPosition();
        AnalyticsController.instance.recordEvent(
          BuyerAnalyticsEvent.shopViewed,
          targetId: shopId,
          data: {'lat': position.latitude, 'lon': position.longitude},
        );
      } catch (_) {
        AnalyticsController.instance.recordEvent(
          BuyerAnalyticsEvent.shopViewed,
          targetId: shopId,
        );
      }

      // Fetch full shop details (which now includes reviewStats and userReview) and inventory
      final results = await Future.wait([
        _shopServices.getShopById(shopId),
        _productServices.getProductsByShopId(shopId),
      ]);

      final shopResponse = results[0] as ShopResponse;
      final productsResponse = results[1] as ProductListResponse;

      if (shopResponse.isSuccess && productsResponse.isSuccess) {
        if (shopResponse.shop != null) {
          emit(
            ShopDetailSuccess(
              shop: shopResponse.shop!,
              inventory: productsResponse.products,
              reviewStats: shopResponse.shop!.reviewStats,
            ),
          );
        } else {
          if (state is! ShopDetailSuccess) {
            emit(const ShopDetailFailure('Shop details not found'));
          } else {
            final successState = state as ShopDetailSuccess;
            emit(
              ShopDetailSuccess(
                shop: successState.shop,
                inventory: successState.inventory,
                reviewStats: successState.reviewStats,
              ),
            );
          }
        }
      } else {
        final errorMessage = (!shopResponse.isSuccess)
            ? ((shopResponse.message ?? '').isEmpty
                  ? 'Failed to load shop data'
                  : shopResponse.message!)
            : ((productsResponse.message ?? '').isEmpty
                  ? 'Failed to load items'
                  : productsResponse.message!);

        if (state is! ShopDetailSuccess) {
          emit(ShopDetailFailure(errorMessage));
        } else {
          final successState = state as ShopDetailSuccess;
          emit(
            ShopDetailSuccess(
              shop: successState.shop,
              inventory: successState.inventory,
              reviewStats: successState.reviewStats,
            ),
          );
          debugPrint('Silent shop detail refresh failure: $errorMessage');
        }
      }
    } catch (e) {
      if (state is! ShopDetailSuccess) {
        emit(ShopDetailFailure(e.toString()));
      } else {
        final successState = state as ShopDetailSuccess;
        emit(
          ShopDetailSuccess(
            shop: successState.shop,
            inventory: successState.inventory,
            reviewStats: successState.reviewStats,
          ),
        );
        debugPrint('Silent shop detail refresh exception: $e');
      }
    }
  }
}
