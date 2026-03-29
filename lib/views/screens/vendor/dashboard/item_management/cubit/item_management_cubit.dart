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
      if (_items.isEmpty) {
        emit(ItemManagementFailure(response.message));
      }
    }
  }

  /// Upload a list of image files and return their URLs.
  /// Merges with any [existingUrls] that the user kept.
  Future<List<String>?> _uploadImages(
    List<File> newFiles,
    List<String> existingUrls,
  ) async {
    final List<String> allUrls = List.from(existingUrls);

    for (int i = 0; i < newFiles.length; i++) {
      emit(ItemActionLoading(message: 'Uploading image ${i + 1}/${newFiles.length}...'));
      final url = await MediaServices.uploadImage(newFiles[i]);
      if (url == null) return null; // Signal failure
      allUrls.add(url);
    }

    return allUrls;
  }

  Future<void> createItem(CreateItemInput input, {List<File> imageFiles = const []}) async {
    emit(const ItemActionLoading());

    final imageUrls = await _uploadImages(imageFiles, input.imageUrls);
    if (imageUrls == null) {
      emit(const ItemManagementFailure('Failed to upload product images'));
      return;
    }

    final finalInput = CreateItemInput(
      shopId: input.shopId,
      name: input.name,
      description: input.description,
      price: input.price,
      unit: input.unit,
      stockCount: input.stockCount,
      imageUrls: imageUrls,
      discount: input.discount,
    );

    final response = await _itemServices.createItem(finalInput);
    if (response.success) {
      emit(ItemActionSuccess(response.message));
      _items = [];
      fetchItems();
    } else {
      emit(ItemManagementFailure(response.message));
    }
  }

  Future<void> updateItem(UpdateItemInput input, {List<File> imageFiles = const []}) async {
    emit(const ItemActionLoading());

    final imageUrls = await _uploadImages(imageFiles, input.imageUrls ?? []);
    if (imageUrls == null) {
      emit(const ItemManagementFailure('Failed to upload updated images'));
      return;
    }

    final finalInput = UpdateItemInput(
      id: input.id,
      name: input.name,
      description: input.description,
      price: input.price,
      unit: input.unit,
      stockCount: input.stockCount,
      imageUrls: imageUrls,
      discount: input.discount,
    );

    final response = await _itemServices.updateItem(finalInput);
    if (response.success) {
      emit(ItemActionSuccess(response.message));
      _items = [];
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
      _items = [];
      fetchItems();
    } else {
      emit(ItemManagementFailure(response.message ?? 'Failed to delete item'));
    }
  }
}
