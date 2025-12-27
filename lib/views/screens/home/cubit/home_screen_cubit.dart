import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/ui_models/categories_list.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit() : super(HomeScreenInitial()) {
    _initialize();
  }

  // Variables stored in the Cubit, as requested
  List<ShopModel> _allShops = [];
  String _selectedCategory = CategoriesList.All;

  // Public getters if needed by widgets outside BlocBuilder
  String get selectedCategory => _selectedCategory;
  List<ShopModel> get filteredShops => _getFilteredShops();

  Future<void> _initialize() async {
    await loadShops();
  }

  Future<void> loadShops() async {
    emit(HomeScreenLoading());

    try {
      _allShops = [
        ShopModel(
          name: 'Grocers Galore',
          image:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=200&auto=format&fit=crop',
          category: CategoriesList.Groceries,
          location: 'Uptown',
        ),
        ShopModel(
          name: 'Grocers Galore',
          image:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=200&auto=format&fit=crop',
          category: CategoriesList.Groceries,
          location: 'Uptown',
        ),
        ShopModel(
          name: 'Tech Tools',
          image:
              'https://images.unsplash.com/photo-1531297484001-80022131f5a1?q=80&w=200&auto=format&fit=crop',
          category: CategoriesList.Software,
          location: 'Silicon Valley',
        ),
        ShopModel(
          name: 'Health Haven',
          image:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=200&auto=format&fit=crop',
          category: CategoriesList.Health,
          location: 'Medical Center',
        ),
        ShopModel(
          name: 'Bakery Bliss',
          image:
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=200&auto=format&fit=crop',
          category: CategoriesList.Bakery,
          location: 'Sweet Street',
        ),
        ShopModel(
          name: 'Service Squad',
          image:
              'https://images.unsplash.com/photo-1454165833767-1316b0215b3f?q=80&w=200&auto=format&fit=crop',
          category: CategoriesList.Services,
          location: 'City Center',
        ),
      ];

      emit(
        HomeScreenSuccess(
          shops: _getFilteredShops(),
          category: _selectedCategory,
        ),
      );
    } catch (e) {
      emit(HomeScreenFailure(e.toString()));
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;

    emit(
      HomeScreenSuccess(
        shops: _getFilteredShops(),
        category: _selectedCategory,
      ),
    );
  }

  List<ShopModel> _getFilteredShops() {
    return _selectedCategory == CategoriesList.All
        ? List.from(_allShops)
        : _allShops
              .where((shop) => shop.category == _selectedCategory)
              .toList();
  }

  @override
  Future<void> close() async {
    // Clean up any listeners or subscriptions here if added later
    await super.close();
  }
}
