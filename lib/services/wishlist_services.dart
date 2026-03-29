import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class CreateWishlistInput {
  final String itemName;
  final String? description;
  final String? categoryId;
  final double lat;
  final double lon;

  CreateWishlistInput({
    required this.itemName,
    this.description,
    this.categoryId,
    required this.lat,
    required this.lon,
  });

  Map<String, dynamic> toJson() {
    return {
      "itemName": itemName,
      if (description != null && description!.isNotEmpty)
        "description": description,
      if (categoryId != null && categoryId!.isNotEmpty)
        "categoryId": categoryId,
      "lat": lat,
      "lon": lon,
    };
  }
}

class WishlistServices {
  Future<Map<String, dynamic>> createWishlist(CreateWishlistInput input) async {
    final response = await Server.post(
      ApiConstants.createWishlist,
      data: input.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMyWishlists(
      {int page = 1, int limit = 10}) async {
    final response = await Server.get(
      ApiConstants.getMyWishlists,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteWishlist(String id) async {
    final response = await Server.delete(
      "${ApiConstants.deleteWishlist}$id",
    );
    return response.data;
  }

  Future<Map<String, dynamic>> completeWishlist(String id) async {
    final response = await Server.patch(
      "${ApiConstants.completeWishlist}$id/complete",
    );
    return response.data;
  }

  Future<Map<String, dynamic>> exploreLocalDemand({
    required double lat,
    required double lon,
    double radius = 5000,
  }) async {
    final response = await Server.get(
      ApiConstants.exploreWishlists,
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'radius': radius,
      },
    );
    return response.data;
  }
}
