import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';

part 'explore_screen_state.dart';

class CategoryCacheEntry {
  final List<Shop> shops;
  final int currentPage;
  final bool hasReachedMax;
  final String? apiMessage;
  final bool isGlobalFallback;
  final String? rangeMessage;

  CategoryCacheEntry({
    required this.shops,
    required this.currentPage,
    required this.hasReachedMax,
    this.apiMessage,
    this.isGlobalFallback = false,
    this.rangeMessage,
  });
}

class ExploreScreenCubit extends Cubit<ExploreScreenState>
    with AnalyticsMixin<ExploreScreenState> {
  final ShopServices _shopServices = ShopServices();

  ExploreScreenCubit() : super(ExploreScreenInitial()) {
    _initialize();
    initAnalytics('explore_screen');
  }

  // Variables stored in the Cubit
  List<Shop> _allShops = [];
  List<CategoryModel> _categories = [CategoryModel.all()];
  CategoryModel _selectedCategory = CategoryModel.all();
  String? _apiMessage;
  String? _searchQuery;
  bool _isGlobalFallback = false;
  String? _rangeMessage;

  // Pagination state variables
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _isLoadingNextPage = false;
  int _loadSessionId = 0;

  // Cache for shops and their pagination metadata by category ID
  final Map<String, CategoryCacheEntry> _shopCache = {};

  // Public getters accessed by the UI
  List<Shop> get shops => _allShops;
  List<CategoryModel> get categories => _categories;
  CategoryModel get selectedCategory => _selectedCategory;
  String? get apiMessage => _apiMessage;
  bool get isGlobalFallback => _isGlobalFallback;
  String? get rangeMessage => _rangeMessage;
  bool get isLoadingNextPage => _isLoadingNextPage;

  Future<void> _initialize() async {
    emit(ExploreScreenLoading(timestamp: DateTime.now().millisecondsSinceEpoch));
    try {
      final cats = await _shopServices.getCategoryNames();
      _categories = [CategoryModel.all(), ...cats];
      await loadShops();
    } catch (e) {
      emit(ExploreScreenFailure(e.toString()));
    }
  }

  Future<void> loadShops() async {
    emit(ExploreScreenLoading(timestamp: DateTime.now().millisecondsSinceEpoch));
    _currentPage = 1;
    _allShops.clear(); // Clear old shops immediately to prevent stale data display and duplicate appends
    _hasReachedMax = false;
    _isLoadingNextPage = false;
    _loadSessionId++;
    final currentSession = _loadSessionId;

    try {
      final lat = AppData().latitude;
      final lon = AppData().longitude;

      if (lat == null || lon == null) {
        emit(const ExploreScreenNoLocation());
        return;
      }

      await _fetchShops(lat: lat, lon: lon, sessionId: currentSession);
    } catch (e) {
      if (currentSession == _loadSessionId) {
        emit(ExploreScreenFailure(e.toString()));
      }
    }
  }

  /// Call after the user sets location from the picker.
  Future<void> reloadAfterLocationSet() => loadShops();

  Future<void> _fetchShops({
    required double lat,
    required double lon,
    required int sessionId,
  }) async {
    final cacheKey = _selectedCategory.id;

    // Check cache first - only if not searching and loading page 1
    if ((_searchQuery == null || _searchQuery!.isEmpty) &&
        _currentPage == 1 &&
        _shopCache.containsKey(cacheKey)) {
      final entry = _shopCache[cacheKey]!;
      _allShops = List.from(entry.shops);
      _currentPage = entry.currentPage;
      _hasReachedMax = entry.hasReachedMax;
      _apiMessage = entry.apiMessage;
      _isGlobalFallback = entry.isGlobalFallback;
      _rangeMessage = entry.rangeMessage;

      if (sessionId == _loadSessionId) {
        emit(ExploreScreenSuccess(timestamp: DateTime.now().millisecondsSinceEpoch));
      }
      return;
    }

    try {
      final radiusKm = AppData().discoveryRadius ?? 10.0;
      final radius = (radiusKm * 1000).toInt();

      final response = _searchQuery != null && _searchQuery!.isNotEmpty
          ? await _shopServices.searchShops(
              lat: lat,
              lon: lon,
              query: _searchQuery!,
              radius: radius,
              page: _currentPage,
              limit: 20,
            )
          : await _shopServices.getNearbyShops(
              lat: lat,
              lon: lon,
              radius: radius,
              categoryId: _selectedCategory.id,
              page: _currentPage,
              limit: 20,
            );

      if (sessionId != _loadSessionId) {
        return; // Ignore obsolete request
      }

      if (response.isSuccess ||
          response.status == 410 ||
          response.status == 404) {
        _apiMessage = (response.status == 410 || response.status == 404)
            ? response.message
            : null;
        _isGlobalFallback = response.isGlobalFallback;
        _rangeMessage = response.rangeMessage;

        final newShops = response.shops;
        if (_currentPage == 1) {
          _allShops = newShops;
        } else {
          _allShops.addAll(newShops);
        }

        if (newShops.length < 20) {
          _hasReachedMax = true;
        }

        // Update cache only if not searching
        if (_searchQuery == null || _searchQuery!.isEmpty) {
          _shopCache[cacheKey] = CategoryCacheEntry(
            shops: List.from(_allShops),
            currentPage: _currentPage,
            hasReachedMax: _hasReachedMax,
            apiMessage: _apiMessage,
            isGlobalFallback: _isGlobalFallback,
            rangeMessage: _rangeMessage,
          );
        }

        emit(ExploreScreenSuccess(timestamp: DateTime.now().millisecondsSinceEpoch));
      } else {
        emit(ExploreScreenFailure(response.message ?? 'An error occurred'));
      }
    } catch (e) {
      if (sessionId == _loadSessionId) {
        emit(ExploreScreenFailure(e.toString()));
      }
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoadingNextPage || _hasReachedMax) return;

    final lat = AppData().latitude;
    final lon = AppData().longitude;

    if (lat == null || lon == null) {
      return;
    }

    _isLoadingNextPage = true;
    emit(ExploreScreenSuccess(timestamp: DateTime.now().millisecondsSinceEpoch));

    _currentPage++;
    final requestedPage = _currentPage;
    final currentSession = _loadSessionId;

    try {
      final radiusKm = AppData().discoveryRadius ?? 10.0;
      final radius = (radiusKm * 1000).toInt();

      final response = _searchQuery != null && _searchQuery!.isNotEmpty
          ? await _shopServices.searchShops(
              lat: lat,
              lon: lon,
              query: _searchQuery!,
              radius: radius,
              page: requestedPage,
              limit: 20,
            )
          : await _shopServices.getNearbyShops(
              lat: lat,
              lon: lon,
              radius: radius,
              categoryId: _selectedCategory.id,
              page: requestedPage,
              limit: 20,
            );

      // Verify that both the operation session and requested page remain valid
      if (currentSession != _loadSessionId || requestedPage != _currentPage) {
        return; // Ignore obsolete request
      }

      if (response.isSuccess ||
          response.status == 410 ||
          response.status == 404) {
        _apiMessage = (response.status == 410 || response.status == 404)
            ? response.message
            : null;
        _isGlobalFallback = response.isGlobalFallback;
        _rangeMessage = response.rangeMessage;

        final newShops = response.shops;
        _allShops.addAll(newShops);

        if (newShops.length < 20) {
          _hasReachedMax = true;
        }

        if (_searchQuery == null || _searchQuery!.isEmpty) {
          _shopCache[_selectedCategory.id] = CategoryCacheEntry(
            shops: List.from(_allShops),
            currentPage: _currentPage,
            hasReachedMax: _hasReachedMax,
            apiMessage: _apiMessage,
            isGlobalFallback: _isGlobalFallback,
            rangeMessage: _rangeMessage,
          );
        }
      } else {
        _currentPage--;
      }
    } catch (e) {
      if (currentSession == _loadSessionId && requestedPage == _currentPage) {
        _currentPage--;
      }
    } finally {
      if (currentSession == _loadSessionId && requestedPage == _currentPage) {
        _isLoadingNextPage = false;
        emit(ExploreScreenSuccess(timestamp: DateTime.now().millisecondsSinceEpoch));
      }
    }
  }

  void selectCategory(CategoryModel category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _searchQuery = null;
    loadShops();
  }

  void searchShops(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _selectedCategory = CategoryModel.all();
    loadShops();
  }

  void clearSearch() {
    if (_searchQuery == null) return;
    _searchQuery = null;
    loadShops();
  }

  Future<void> refreshShops() async {
    _shopCache.clear();
    await _initialize();
  }

  @override
  Future<void> close() async {
    await closeAnalytics();
    await super.close();
  }
}
