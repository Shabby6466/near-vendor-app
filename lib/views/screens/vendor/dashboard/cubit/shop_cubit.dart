import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/services/vendor_services.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final VendorServices _vendorServices = VendorServices();

  ShopCubit() : super(ShopInitial());

  Future<void> fetchMyShops() async {
    emit(ShopLoading());
    try {
      final shops = await _vendorServices.getMyShops();
      emit(ShopListLoaded(shops));
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }

  Future<void> createShop(CreateShopInput input) async {
    emit(ShopLoading());
    try {
      final response = await _vendorServices.createShop(input);
      if (response.status == 200) {
        emit(ShopActionSuccess(response.message ?? 'Shop created successfully'));
        await fetchMyShops();
      } else {
        emit(ShopFailure(response.message ?? 'Failed to create shop'));
      }
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }

  Future<void> updateShop(UpdateShopInput input) async {
    emit(ShopLoading());
    try {
      await _vendorServices.updateShop(input);
      emit(const ShopActionSuccess('Shop updated successfully'));
      await fetchMyShops();
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }

  Future<void> deleteShop(String shopId) async {
    emit(ShopLoading());
    try {
      final response = await _vendorServices.deleteShop(DeleteShopInput(shopId: shopId));
      if (response.status == 200) {
        emit(ShopActionSuccess(response.message ?? 'Shop deleted successfully'));
        await fetchMyShops();
      } else {
        emit(ShopFailure(response.message ?? 'Failed to delete shop'));
      }
    } catch (e) {
      emit(ShopFailure(e.toString()));
    }
  }
}
