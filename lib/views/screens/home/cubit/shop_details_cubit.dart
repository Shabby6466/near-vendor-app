import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/services/item_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'shop_details_state.dart';

class ShopDetailsCubit extends Cubit<ShopDetailsState> with AnalyticsMixin<ShopDetailsState> {
  final ShopServices _shopServices = ShopServices();
  final ItemServices _itemServices = ItemServices();

  ShopDetailsCubit() : super(ShopDetailsInitial()) {
    initAnalytics('shop_details_screen');
  }

  Future<void> loadShopData(String shopId) async {
    emit(ShopDetailsLoading());

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
        updateAnalyticsMetadata({
          'shopId': shopId,
        });
      }

      // Fetch shop details and inventory in parallel
      final results = await Future.wait([
        _shopServices.getShopById(shopId),
        _itemServices.getItemsByShopId(shopId),
      ]);

      final shopResponse = results[0] as dynamic; // ShopResponse
      final itemsResponse = results[1] as dynamic; // ItemListResponse

      if (shopResponse.success && itemsResponse.success) {
        if (shopResponse.shop != null) {
          emit(
            ShopDetailsSuccess(
              shop: shopResponse.shop!,
              inventory: itemsResponse.items,
            ),
          );
        } else {
          emit(const ShopDetailsFailure('Shop details not found'));
        }
      } else {
        final errorMessage = !shopResponse.success 
            ? shopResponse.message 
            : itemsResponse.message;
        emit(ShopDetailsFailure(errorMessage));
      }
    } catch (e) {
      emit(ShopDetailsFailure(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await closeAnalytics();
    await super.close();
  }
}
