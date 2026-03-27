import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'shop_form_state.dart';

class ShopFormCubit extends Cubit<ShopFormState> {
  final ShopServices _shopServices = ShopServices();

  ShopFormCubit() : super(ShopFormInitial());

  Future<void> createShop(CreateShopInput input) async {
    emit(ShopFormLoading());
    final response = await _shopServices.createShop(input);
    print('create shop response: $response');
    if (response.statusCode == 200 || response.statusCode == 201) {
      emit(ShopFormSuccess());
    } else {
      emit(ShopFormFailure(response.message));
    }
  }

  Future<void> updateShop(UpdateShopInput input) async {
    emit(ShopFormLoading());
    final response = await _shopServices.updateShop(input);
    if (response.success && response.shop != null) {
      emit(ShopFormSuccess(shop: response.shop!, isUpdate: true));
    } else {
      emit(ShopFormFailure(response.message));
    }
  }
}
