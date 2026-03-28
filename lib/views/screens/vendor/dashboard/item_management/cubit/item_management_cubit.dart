import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/api_inputs/item_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/api_responses/item_response.dart';
import 'package:nearvendorapp/services/item_services.dart';
import 'package:nearvendorapp/services/media_services.dart';

part 'item_management_state.dart';

class ItemManagementCubit extends Cubit<ItemManagementState> {
  final ItemServices _itemServices = ItemServices();
  final String shopId;

  ItemManagementCubit({required this.shopId}) : super(ItemManagementInitial());


  List<Item> _items = [];
  PaginationMeta? _meta;

  Future<void> fetchItems() async {
    if (_items.isEmpty) {
      emit(ItemManagementLoading());
    } else {
      emit(ItemManagementSuccess(_items, meta: _meta));
    }

    final response = await _itemServices.getItemsByShopId(shopId);
    if (response.success) {
      _items = response.items;
      _meta = response.meta;
      emit(ItemManagementSuccess(_items, meta: _meta));
    } else {
      // If we already have items, we don't necessarily want to show an error screen
      // but maybe just a snackbar? For now, if it's an initial load, show failure.
      if (_items.isEmpty) {
        emit(ItemManagementFailure(response.message));
      }
    }
  }

  Future<void> createItem(CreateItemInput input, {File? imageFile}) async {
    emit(const ItemActionLoading());
    
    String? imageUrl = input.imageUrl;
    if (imageFile != null) {
      emit(const ItemActionLoading(message: 'Uploading image...'));
      imageUrl = await MediaServices.uploadImage(imageFile);
      if (imageUrl == null) {
        emit(const ItemManagementFailure('Failed to upload product image'));
        return;
      }
    }

    final finalInput = CreateItemInput(
      shopId: input.shopId,
      name: input.name,
      description: input.description,
      price: input.price,
      unit: input.unit,
      stockCount: input.stockCount,
      imageUrl: imageUrl,
      discount: input.discount,
    );

    final response = await _itemServices.createItem(finalInput);
    if (response.success) {
      emit(ItemActionSuccess(response.message));
      _items = []; // Clear cache on success to force refresh
      fetchItems();
    } else {
      emit(ItemManagementFailure(response.message));
    }
  }

  Future<void> updateItem(UpdateItemInput input, {File? imageFile}) async {
    emit(const ItemActionLoading());

    String? imageUrl = input.imageUrl;
    if (imageFile != null) {
      emit(const ItemActionLoading(message: 'Uploading new image...'));
      imageUrl = await MediaServices.uploadImage(imageFile);
      if (imageUrl == null) {
        emit(const ItemManagementFailure('Failed to upload updated image'));
        return;
      }
    }

    final finalInput = UpdateItemInput(
      id: input.id,
      name: input.name,
      description: input.description,
      price: input.price,
      unit: input.unit,
      stockCount: input.stockCount,
      imageUrl: imageUrl,
      discount: input.discount,
    );

    final response = await _itemServices.updateItem(finalInput);
    if (response.success) {
      emit(ItemActionSuccess(response.message));
      _items = []; // Clear cache on success
      fetchItems();
    } else {
      emit(ItemManagementFailure(response.message));
    }
  }

  Future<void> deleteItem(String id) async {
    emit(const ItemActionLoading());
    final response = await _itemServices.deleteItem(id);
    if (response.status == 200 || response.status == 201) {
      emit(ItemActionSuccess(response.message ?? 'Item deleted successfully'));
      _items = []; // Clear cache on success
      fetchItems();
    } else {
      emit(ItemManagementFailure(response.message ?? 'Failed to delete item'));
    }
  }
}
