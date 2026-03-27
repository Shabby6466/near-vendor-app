import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'vendor_shop_state.dart';

class VendorShopCubit extends Cubit<VendorShopState> {
  final ShopServices _shopServices = ShopServices();

  VendorShopCubit() : super(VendorShopInitial());

  Future<void> fetchShops() async {
    emit(VendorShopLoading());
    final response = await _shopServices.getMyShops();
    if (response.success) {
      emit(VendorShopSuccess(response.shops));
    } else {
      emit(VendorShopFailure(response.message));
    }
  }

  Future<void> deleteShop(String shopId) async {
    final currentState = state;
    if (currentState is VendorShopSuccess) {
      final response = await _shopServices.deleteShop(
        DeleteShopInput(shopId: shopId),
      );
      if (response.status == 200 || response.status == 201) {
        final updatedShops = currentState.shops
            .where((s) => s.id != shopId)
            .toList();
        emit(VendorShopSuccess(updatedShops));
      }
    }
  }
}
