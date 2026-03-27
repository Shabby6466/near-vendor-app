import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/services/media_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'shop_form_state.dart';

class ShopFormCubit extends Cubit<ShopFormState> {
  final ShopServices _shopServices = ShopServices();

  ShopFormCubit() : super(ShopFormInitial());

  Future<void> createShop(CreateShopInput input, {File? logoFile, File? coverFile}) async {
    try {
      String? logoUrl = input.storeLogoUrl;
      String? coverUrl = input.coverImageUrl;

      if (logoFile != null) {
        emit(const ShopFormLoading(message: 'Uploading logo...'));
        logoUrl = await MediaServices.uploadImage(logoFile);
      }
      if (coverFile != null) {
        emit(const ShopFormLoading(message: 'Uploading cover...'));
        coverUrl = await MediaServices.uploadImage(coverFile);
      }

      emit(const ShopFormLoading(message: 'Launching your business...'));
      final finalInput = CreateShopInput(
        vendorId: input.vendorId,
        shopName: input.shopName,
        businessCategory: input.businessCategory,
        registrationNumber: input.registrationNumber,
        shopAddress: input.shopAddress,
        operatingHours: input.operatingHours,
        shopLongitude: input.shopLongitude,
        shopLatitude: input.shopLatitude,
        shopContactPhone: input.shopContactPhone,
        whatsappNumber: input.whatsappNumber,
        storeEmail: input.storeEmail,
        storeLogoUrl: logoUrl,
        coverImageUrl: coverUrl,
      );

      final response = await _shopServices.createShop(finalInput);
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(const ShopFormSuccess());
      } else {
        emit(ShopFormFailure(response.message));
      }
    } catch (e) {
      emit(ShopFormFailure(e.toString()));
    }
  }

  Future<void> updateShop(UpdateShopInput input, {File? logoFile, File? coverFile}) async {
    try {
      String? logoUrl = input.storeLogoUrl;
      String? coverUrl = input.coverImageUrl;

      if (logoFile != null) {
        emit(const ShopFormLoading(message: 'Updating logo...'));
        logoUrl = await MediaServices.uploadImage(logoFile);
      }
      if (coverFile != null) {
        emit(const ShopFormLoading(message: 'Updating cover...'));
        coverUrl = await MediaServices.uploadImage(coverFile);
      }

      emit(const ShopFormLoading(message: 'Syncing details...'));
      final finalInput = UpdateShopInput(
        vendorId: input.vendorId,
        shopName: input.shopName,
        businessCategory: input.businessCategory,
        registrationNumber: input.registrationNumber,
        shopAddress: input.shopAddress,
        operatingHours: input.operatingHours,
        shopLongitude: input.shopLongitude,
        shopLatitude: input.shopLatitude,
        shopContactPhone: input.shopContactPhone,
        whatsappNumber: input.whatsappNumber,
        storeEmail: input.storeEmail,
        storeLogoUrl: logoUrl,
        coverImageUrl: coverUrl,
        isActive: input.isActive,
      );

      final response = await _shopServices.updateShop(finalInput);
      if (response.success && response.shop != null) {
        emit(ShopFormSuccess(shop: response.shop!, isUpdate: true));
      } else {
        emit(ShopFormFailure(response.message));
      }
    } catch (e) {
      emit(ShopFormFailure(e.toString()));
    }
  }
}
