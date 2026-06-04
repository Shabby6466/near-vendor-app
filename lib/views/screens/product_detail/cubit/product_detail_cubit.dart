import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/item_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState>
    with AnalyticsMixin<ProductDetailState> {
  final ItemServices _itemServices = ItemServices();
  final ShopServices _shopServices = ShopServices();

  ProductDetailCubit() : super(ProductDetailInitial()) {
    initAnalytics('product_detail_screen');
  }

  Future<void> fetchDetails(String itemId) async {
    emit(ProductDetailLoading());
    try {
      // 1. Fetch Product Details
      final itemResponse = await _itemServices.getItemById(itemId);
      if (itemResponse.success != true) {
        emit(
          ProductDetailFailure(
            itemResponse.message ?? 'Failed to load product',
          ),
        );
        return;
      }

      final item = itemResponse.item;
      if (item == null) {
        emit(const ProductDetailFailure('Product details not found'));
        return;
      }

      // 2. Fetch Shop Details (for the portfolio view)
      Shop? shop;
      if (item.shopId != null) {
        try {
          final shopResponse = await _shopServices.getShopById(item.shopId!);
          if (shopResponse.success == true) {
            shop = shopResponse.shop;
          }
        } catch (e) {
          debugPrint('Error fetching shop details: $e');
        }
      }

      emit(ProductDetailSuccess(item: item, shop: shop));
    } catch (e) {
      emit(ProductDetailFailure(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await closeAnalytics();
    await super.close();
  }
}
