import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/services/item_services.dart';

part 'item_detail_state.dart';

class ItemDetailCubit extends Cubit<ItemDetailState> {
  final ItemServices _itemServices = ItemServices();

  ItemDetailCubit() : super(ItemDetailInitial());

  Future<void> fetchItemById(String id) async {
    emit(ItemDetailLoading());
    final response = await _itemServices.getItemById(id);
    if (response.success && response.item != null) {
      emit(ItemDetailSuccess(response.item!));
    } else {
      emit(ItemDetailFailure(response.message));
    }
  }
}
