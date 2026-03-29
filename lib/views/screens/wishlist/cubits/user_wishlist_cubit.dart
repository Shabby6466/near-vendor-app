import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/wishlist_model.dart';
import 'package:nearvendorapp/services/wishlist_services.dart';

part 'user_wishlist_state.dart';

class UserWishlistCubit extends Cubit<UserWishlistState> {
  final WishlistServices _wishlistServices = WishlistServices();
  int _currentPage = 1;
  bool _hasMore = true;

  UserWishlistCubit() : super(UserWishlistInitial());

  Future<void> getMyWishlists({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      emit(UserWishlistLoading());
    } else if (state is UserWishlistLoaded) {
      if (!_hasMore) return;
      emit((state as UserWishlistLoaded).copyWith(isFetchingMore: true));
    } else {
      emit(UserWishlistLoading());
    }

    try {
      final response = await _wishlistServices.getMyWishlists(
          page: _currentPage, limit: 10);
      if (response['statusCode'] == 200 || response['statusCode'] == 2000 || response['success'] == true) {
        final data = response['data'];
        List itemsJson = [];
        Map? meta;

        if (data is List) {
          itemsJson = data;
        } else if (data is Map) {
          itemsJson = data['items'] ?? [];
          meta = data['meta'];
        }

        final items = itemsJson.map((e) => WishlistItem.fromJson(e)).toList();

        if (meta != null) {
          final totalPages = meta['totalPages'] ?? 1;
          _hasMore = _currentPage < totalPages;
        } else {
          _hasMore = false;
        }

        if (state is UserWishlistLoaded && !refresh) {
          final currentItems = (state as UserWishlistLoaded).wishlists;
          emit(UserWishlistLoaded(
            wishlists: [...currentItems, ...items],
            hasMore: _hasMore,
          ));
        } else {
          emit(UserWishlistLoaded(
            wishlists: items,
            hasMore: _hasMore,
          ));
        }
        _currentPage++;
      } else {
        emit(UserWishlistError(
            message: response['message'] ?? 'Failed to fetch wishlists'));
      }
    } catch (e) {
      emit(UserWishlistError(message: e.toString()));
    }
  }

  Future<bool> createWishlist(CreateWishlistInput input) async {
    try {
      final response = await _wishlistServices.createWishlist(input);
      if (response['statusCode'] == 200 || response['statusCode'] == 2000 || response['success'] == true) {
        // Refresh the list after successfully creating
        getMyWishlists(refresh: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteWishlist(String id) async {
    try {
      final response = await _wishlistServices.deleteWishlist(id);
      if (response['statusCode'] == 200 || response['statusCode'] == 2000 || response['success'] == true) {
        if (state is UserWishlistLoaded) {
          final currentItems = (state as UserWishlistLoaded).wishlists;
          emit(UserWishlistLoaded(
            wishlists: currentItems.where((w) => w.id != id).toList(),
            hasMore: _hasMore,
          ));
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeWishlist(String id) async {
    try {
      final response = await _wishlistServices.completeWishlist(id);
      if (response['statusCode'] == 200 || response['statusCode'] == 2000 || response['success'] == true) {
        if (state is UserWishlistLoaded) {
          final currentItems = (state as UserWishlistLoaded).wishlists;
          final updatedItems = currentItems.map((w) {
            if (w.id == id) {
              return WishlistItem(
                id: w.id,
                itemName: w.itemName,
                description: w.description,
                categoryId: w.categoryId,
                status: 'FULFILLED',
                createdAt: w.createdAt,
                matchedItems: w.matchedItems,
              );
            }
            return w;
          }).toList();
          
          emit(UserWishlistLoaded(
            wishlists: updatedItems,
            hasMore: _hasMore,
          ));
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
