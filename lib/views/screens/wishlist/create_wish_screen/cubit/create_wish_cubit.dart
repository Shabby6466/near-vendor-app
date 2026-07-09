import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/categories_service.dart';
import 'package:nearvendorapp/services/wishlist_services.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';

part 'create_wish_state.dart';

class CreateWishCubit extends Cubit<CreateWishState> {
  CreateWishCubit() : super(CreateWishInitial());

  final WishlistServices _wishlistServices = WishlistServices();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;

  void selectCategory(CategoryModel? category) {
    _selectedCategory = category;
    emit(CreateWishCategoriesLoaded(
      selectedCategory: category,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> loadCategories() async {
    try {
      final response = await CategoriesService.getProductCategories();
      _categories
        ..clear()
        ..addAll(response.categories);
      emit(CreateWishCategoriesLoaded(
        selectedCategory: _selectedCategory,
        timestamp: DateTime.now(),
      ));
    } catch (_) {
      _categories.clear();
      emit(CreateWishCategoriesLoaded(
        selectedCategory: _selectedCategory,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final location = await LocationPickerLauncher.ensureLocation(context);
    if (location == null) return;

    emit(CreateWishSubmitting());

    final success = await _wishlistServices.createWishlist(
      CreateWishlistInput(
        itemName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        categoryId: (_selectedCategory?.id.isNotEmpty ?? false)
            ? _selectedCategory!.id
            : null,
        lat: location.latitude,
        lon: location.longitude,
      ),
    );

    if (success.isSuccess) {
      loadCategories();
      emit(CreateWishSuccess());
    } else {
      emit(const CreateWishFailure('Failed to create wish. Please try again.'));
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    descriptionController.dispose();
    return super.close();
  }
}
