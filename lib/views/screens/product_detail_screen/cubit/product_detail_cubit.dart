import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/product_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState>
    with AnalyticsMixin<ProductDetailState> {
  final ProductServices _productServices = ProductServices();
  final ShopServices _shopServices = ShopServices();

  ProductDetailCubit({Product? initialProduct})
    : super(
        initialProduct != null &&
                initialProduct.id.isNotEmpty &&
                initialProduct.name.isNotEmpty &&
                initialProduct.shop != null &&
                (initialProduct.shop!['id']?.toString().isNotEmpty ?? false) &&
                (initialProduct.shop!['shopName']?.toString().isNotEmpty ??
                    false)
            ? ProductDetailSuccess(
                item: initialProduct,
                shop: Shop.fromJson(initialProduct.shop!),
              )
            : ProductDetailInitial(),
      ) {
    initAnalytics('product_detail_screen');
  }

  Future<void> fetchDetails(String itemId) async {
    if (state is! ProductDetailSuccess) {
      emit(ProductDetailLoading());
    }
    try {
      // 1. Fetch Product Details
      final productResponse = await _productServices.getProductById(itemId);
      if (!productResponse.isSuccess) {
        if (state is! ProductDetailSuccess) {
          emit(
            ProductDetailFailure(
              productResponse.message ?? 'Failed to load product',
            ),
          );
        } else {
          debugPrint('Silent product refresh failure: ${productResponse.message}');
        }
        return;
      }

      final item = productResponse.item;
      if (item == null) {
        if (state is! ProductDetailSuccess) {
          emit(const ProductDetailFailure('Product details not found'));
        } else {
          debugPrint('Silent product refresh failure: Product details not found');
        }
        return;
      }

      // 2. Fetch Shop Details (for the portfolio view)
      Shop? shop;
      if (item.shopId != null) {
        try {
          final shopResponse = await _shopServices.getShopById(item.shopId!);
          if (shopResponse.isSuccess) {
            shop = shopResponse.shop;
          }
        } catch (e) {
          debugPrint('Error fetching shop details: $e');
        }
      }

      emit(ProductDetailSuccess(item: item, shop: shop));
    } catch (e) {
      if (state is! ProductDetailSuccess) {
        emit(ProductDetailFailure(e.toString()));
      } else {
        debugPrint('Silent product refresh exception: $e');
      }
    }
  }

  @override
  Future<void> close() async {
    await closeAnalytics();
    await super.close();
  }
}
