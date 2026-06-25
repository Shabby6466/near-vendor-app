import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/safety_services.dart';

part 'blocked_shops_state.dart';

class BlockedShop extends Equatable {
  final String blockedShopId;
  final String shopName;
  final String shopLogoUrl;

  const BlockedShop({
    required this.blockedShopId,
    required this.shopName,
    required this.shopLogoUrl,
  });

  factory BlockedShop.fromJson(Map<String, dynamic> json) {
    return BlockedShop(
      blockedShopId: json['blockedShopId'] as String? ?? '',
      shopName: json['shopName'] as String? ?? 'Shop',
      shopLogoUrl: json['shopLogoUrl'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [blockedShopId, shopName, shopLogoUrl];
}

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
        emit(BlockedShopsFailure(response.message ?? 'Failed to load blocked shops'));
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
