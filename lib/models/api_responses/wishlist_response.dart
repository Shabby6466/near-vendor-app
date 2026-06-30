import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/wishlist_model.dart';

/// Response for POST /wishlists — create a wish.
class CreateWishlistResponse extends BaseApiResponse {
  WishlistItem? wishlist;

  CreateWishlistResponse({
    super.status,
    super.statusCode,
    super.message,
    this.wishlist,
  });

  CreateWishlistResponse.fromJson(dynamic json)
    : super.fromJson(json) {
    if (json is Map) {
      final data = json['data'];
      if (data is Map) {
        wishlist = WishlistItem.fromJson(data as Map<String, dynamic>);
      }
    }
  }
}

/// Response for GET /wishlists/my — paginated list.
class GetWishlistsResponse extends BaseApiResponse {
  List<WishlistItem> wishlists = [];
  int? totalPages;
  int? currentPage;

  GetWishlistsResponse({
    super.status,
    super.statusCode,
    super.message,
    List<WishlistItem>? wishlists,
    this.totalPages,
    this.currentPage,
  }) {
    if (wishlists != null) {
      this.wishlists = wishlists;
    }
  }

  GetWishlistsResponse.fromJson(dynamic json)
    : super.fromJson(json) {
    if (json is Map) {
      final data = json['data'];
      List<dynamic> raw = [];
      Map<String, dynamic>? meta;

      if (data is List) {
        raw = data;
      } else if (data is Map) {
        raw = data['items'] as List<dynamic>? ?? [];
        meta = data['meta'] as Map<String, dynamic>?;
      }

      wishlists = raw
          .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
          .toList();
      totalPages = meta?['totalPages'] as int?;
      currentPage = meta?['currentPage'] as int?;
    }
  }
}

/// Generic response for delete / complete / patch operations.
class WishlistActionResponse extends BaseApiResponse {
  WishlistActionResponse({
    super.status,
    super.statusCode,
    super.message,
  });

  WishlistActionResponse.fromJson(dynamic json)
    : super.fromJson(json);
}

/// Response for GET /wishlists/explore — vendor demand feed.
class ExploreDemandResponse extends BaseApiResponse {
  List<WishlistItem> demands = [];

  ExploreDemandResponse({
    super.status,
    super.statusCode,
    super.message,
    List<WishlistItem>? demands,
  }) {
    if (demands != null) {
      this.demands = demands;
    }
  }

  ExploreDemandResponse.fromJson(dynamic json)
    : super.fromJson(json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        demands = data
            .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
  }
}
