import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/blocked_shop.dart';
import 'package:nearvendorapp/services/safety_services.dart';

part 'blocked_shops_state.dart';

class BlockedShopsCubit extends Cubit<BlockedShopsState> {
  BlockedShopsCubit() : super(BlockedShopsInitial());

  final _safetyServices = SafetyServices();

  Future<void> fetchBlockedShops() async {
    emit(BlockedShopsLoading());
    try {
      final response = await _safetyServices.getBlockedShops();
      if (response.isSuccess) {
        emit(BlockedShopsSuccess(shops: response.shops));
      } else {
        emit(
          BlockedShopsFailure(
            response.message ?? 'Failed to load blocked shops',
          ),
        );
      }
    } catch (e) {
      emit(BlockedShopsFailure(e.toString()));
    }
  }

  Future<bool> unblockShop(String shopId) async {
    try {
      final response = await _safetyServices.unblockShop(shopId);
      if (response.success == true) {
        // Refresh local state list
        if (state is BlockedShopsSuccess) {
          final currentShops = (state as BlockedShopsSuccess).shops;
          final updatedShops = currentShops
              .where((s) => s.blockedShopId != shopId)
              .toList();
          emit(BlockedShopsSuccess(shops: updatedShops));
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
