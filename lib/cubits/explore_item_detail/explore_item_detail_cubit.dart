import 'package:bloc/bloc.dart';
import 'package:nearvendorapp/services/item_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'explore_item_detail_state.dart';

class ExploreItemDetailCubit extends Cubit<ExploreItemDetailState> {
  final ItemServices _itemServices = ItemServices();
  final ShopServices _shopServices = ShopServices();

  ExploreItemDetailCubit() : super(ExploreItemDetailInitial());

  Future<void> fetchDetails(String itemId) async {
    emit(ExploreItemDetailLoading());
    try {
      // 1. Fetch Item Details
      final itemResponse = await _itemServices.getItemById(itemId);
      if (!itemResponse.success) {
        emit(ExploreItemDetailFailure(itemResponse.message));
        return;
      }

      final item = itemResponse.item;
      if (item == null) {
        emit(const ExploreItemDetailFailure('Item details not found'));
        return;
      }

      final shopId = item.shopId;
      if (shopId == null) {
        emit(const ExploreItemDetailFailure('Shop ID not found for this item'));
        return;
      }

      // 2. Fetch Shop Details
      final shopResponse = await _shopServices.getShopById(shopId);
      if (!shopResponse.success) {
        emit(ExploreItemDetailFailure(shopResponse.message));
        return;
      }

      final shop = shopResponse.shop;
      if (shop == null) {
        emit(const ExploreItemDetailFailure('Shop details not found'));
        return;
      }

      emit(ExploreItemDetailSuccess(item, shop));
    } catch (e) {
      emit(ExploreItemDetailFailure(e.toString()));
    }
  }
}
