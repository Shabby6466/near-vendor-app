import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/wishlist_model.dart';
import 'package:nearvendorapp/services/wishlist_services.dart';

part 'vendor_demand_state.dart';

class VendorDemandCubit extends Cubit<VendorDemandState> {
  final WishlistServices _wishlistServices = WishlistServices();

  VendorDemandCubit() : super(VendorDemandInitial());

  Future<void> exploreLocalDemand(
      {required double lat, required double lon, double radius = 5000}) async {
    emit(VendorDemandLoading());
    try {
      final response = await _wishlistServices.exploreLocalDemand(
          lat: lat, lon: lon, radius: radius);
      if (response['success'] == true && response['data'] != null) {
        final List itemsJson = response['data'] ?? [];
        final items = itemsJson.map((e) => WishlistItem.fromJson(e)).toList();

        emit(VendorDemandLoaded(demands: items));
      } else {
        emit(VendorDemandError(
            message: response['message'] ?? 'Failed to fetch local demand'));
      }
    } catch (e) {
      emit(VendorDemandError(message: e.toString()));
    }
  }
}
