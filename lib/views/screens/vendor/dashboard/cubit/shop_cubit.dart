import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final ShopServices _shopServices = ShopServices();

  ShopCubit() : super(ShopInitial());

  Future<void> fetchMyShops() async {
    emit(ShopLoading());
    try {
      final response = await _shopServices.getMyShops();
      if (response.success) {
        emit(ShopListLoaded(response.shops));
      } else {
        emit(ShopFailure(response.message));
      }
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }

  Future<void> createShop(CreateShopInput input) async {
    emit(ShopLoading());
    try {
      final response = await _shopServices.createShop(input);
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ShopActionSuccess(
            response.message.isNotEmpty ? response.message : 'Shop created successfully'));
        await fetchMyShops();
      } else {
        emit(ShopFailure(response.message));
      }
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }

  Future<void> updateShop(UpdateShopInput input) async {
    emit(ShopLoading());
    try {
      final response = await _shopServices.updateShop(input);
      if (response.success) {
        emit(const ShopActionSuccess('Shop updated successfully'));
        await fetchMyShops();
      } else {
        emit(ShopFailure(response.message));
      }
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }

  Future<void> deleteShop(String shopId) async {
    emit(ShopLoading());
    try {
      final response = await _shopServices.deleteShop(DeleteShopInput(shopId: shopId));
      if (response.status == 200 || response.status == 201) {
        emit(ShopActionSuccess(
            response.message ?? 'Shop deleted successfully'));
        await fetchMyShops();
      } else {
        emit(ShopFailure(response.message ?? 'Failed to delete shop'));
      }
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }
}
