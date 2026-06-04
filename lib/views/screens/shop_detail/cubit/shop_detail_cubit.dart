import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/api_responses/item_response.dart';
import 'package:nearvendorapp/models/api_responses/shop_response.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/item_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'shop_detail_state.dart';

class ShopDetailCubit extends Cubit<ShopDetailState>
    with AnalyticsMixin<ShopDetailState> {
  final ShopServices _shopServices = ShopServices();
  final ItemServices _itemServices = ItemServices();

  ShopDetailCubit() : super(ShopDetailInitial()) {
    initAnalytics('shop_detail_screen');
  }

  Future<void> loadShopData(String shopId, {Shop? initialShop}) async {
    if (initialShop != null) {
      emit(ShopDetailSuccess(shop: initialShop, inventory: const []));
    } else {
      emit(ShopDetailLoading());
    }

    try {
      // Try to get current position for analytics
      try {
        final position = await Geolocator.getCurrentPosition();
        updateAnalyticsMetadata({
          'lat': position.latitude,
          'lon': position.longitude,
          'shopId': shopId,
        });
      } catch (_) {
        updateAnalyticsMetadata({'shopId': shopId});
      }

      if (initialShop != null) {
        // Only fetch items since we already have the shop details!
        final itemsResponse = await _itemServices.getItemsByShopId(shopId);
        if (itemsResponse.success == true) {
          emit(
            ShopDetailSuccess(
              shop: initialShop,
              inventory: itemsResponse.items,
            ),
          );
        } else {
          emit(
            ShopDetailFailure(
              itemsResponse.message ?? 'Failed to load items',
            ),
          );
        }
      } else {
        // Fetch shop details and inventory in parallel
        final results = await Future.wait([
          _shopServices.getShopById(shopId),
          _itemServices.getItemsByShopId(shopId),
        ]);

        final shopResponse = results[0] as ShopResponse;
        final itemsResponse = results[1] as ItemListResponse;

        if (shopResponse.success == true && itemsResponse.success == true) {
          if (shopResponse.shop != null) {
            emit(
              ShopDetailSuccess(
                shop: shopResponse.shop!,
                inventory: itemsResponse.items,
              ),
            );
          } else {
            emit(const ShopDetailFailure('Shop details not found'));
          }
        } else {
          final errorMessage = (shopResponse.success != true)
              ? ((shopResponse.message ?? '').isEmpty
                    ? 'Failed to load shop data'
                    : shopResponse.message!)
              : ((itemsResponse.message ?? '').isEmpty
                    ? 'Failed to load items'
                    : itemsResponse.message!);
          emit(ShopDetailFailure(errorMessage));
        }
      }
    } catch (e) {
      emit(ShopDetailFailure(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await closeAnalytics();
    await super.close();
  }
}
