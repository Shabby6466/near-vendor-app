import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/shops.dart';
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
      _allShops = ShopsData.dummyShops;
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
