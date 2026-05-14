import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/wishlist_response.dart';
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
      'itemName': itemName,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (categoryId != null && categoryId!.isNotEmpty)
        'categoryId': categoryId,
      'lat': lat,
      'lon': lon,
    };
  }
}

class WishlistServices {
  Future<CreateWishlistResponse> createWishlist(
    CreateWishlistInput input,
  ) async {
    try {
      final response = await Server.post(
        ApiConstants.createWishlist,
        data: input.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return CreateWishlistResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        return CreateWishlistResponse(message: 'Invalid response format');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
          return CreateWishlistResponse.fromJson(e.response!.data as Map<String, dynamic>);
        }
      }
      return CreateWishlistResponse(message: e.toString());
    }
  }

   Future<GetWishlistsResponse> getMyWishlists({
     int page = 1,
     int limit = 10,
   }) async {
     try {
       final response = await Server.get(
         ApiConstants.getMyWishlists,
         queryParameters: {'page': page, 'limit': limit},
       );
       if (response.data is Map<String, dynamic>) {
         return GetWishlistsResponse.fromJson(response.data as Map<String, dynamic>);
       } else {
         return GetWishlistsResponse(message: 'Invalid response format');
       }
     } catch (e) {
       if (e is DioException) {
         if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
           return GetWishlistsResponse.fromJson(e.response!.data as Map<String, dynamic>);
         }
       }
       return GetWishlistsResponse(message: e.toString());
     }
   }

   Future<WishlistActionResponse> deleteWishlist(String id) async {
     try {
       final response = await Server.delete('${ApiConstants.deleteWishlist}$id');
       if (response.data is Map<String, dynamic>) {
         return WishlistActionResponse.fromJson(response.data as Map<String, dynamic>);
       } else {
         return WishlistActionResponse(message: 'Invalid response format');
       }
     } catch (e) {
       if (e is DioException) {
         if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
           return WishlistActionResponse.fromJson(e.response!.data as Map<String, dynamic>);
         }
       }
       return WishlistActionResponse(message: e.toString());
     }
   }

   Future<WishlistActionResponse> completeWishlist(String id) async {
     try {
       final response = await Server.patch(
         '${ApiConstants.completeWishlist}$id/complete',
       );
       if (response.data is Map<String, dynamic>) {
         return WishlistActionResponse.fromJson(response.data as Map<String, dynamic>);
       } else {
         return WishlistActionResponse(message: 'Invalid response format');
       }
     } catch (e) {
       if (e is DioException) {
         if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
           return WishlistActionResponse.fromJson(e.response!.data as Map<String, dynamic>);
         }
       }
       return WishlistActionResponse(message: e.toString());
     }
   }

   Future<ExploreDemandResponse> exploreLocalDemand({
     required double lat,
     required double lon,
     double radius = 5000,
   }) async {
     try {
       final response = await Server.get(
         ApiConstants.exploreWishlists,
         queryParameters: {'lat': lat, 'lon': lon, 'radius': radius},
       );
       if (response.data is Map<String, dynamic>) {
         return ExploreDemandResponse.fromJson(response.data as Map<String, dynamic>);
       } else {
         return ExploreDemandResponse(message: 'Invalid response format');
       }
     } catch (e) {
       if (e is DioException) {
         if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
           return ExploreDemandResponse.fromJson(e.response!.data as Map<String, dynamic>);
         }
       }
       return ExploreDemandResponse(message: e.toString());
     }
   }
}
