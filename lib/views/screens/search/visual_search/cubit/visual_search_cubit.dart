import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/services/search_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'visual_search_state.dart';

class VisualSearchCubit extends Cubit<VisualSearchState> {
  final SearchServices _searchServices = SearchServices();

  VisualSearchCubit() : super(VisualSearchInitial());

  Future<void> searchByImage(File image, {double? customRadiusMeters}) async {
    emit(VisualSearchLoading());

    try {
      // 1. Get location from AppData
      final lat = AppData().latitude;
      final lon = AppData().longitude;

      if (lat == null || lon == null) {
        emit(
          const VisualSearchFailure(
            'Location not set. Please set your location first.',
          ),
        );
        return;
      }

      // 2. Get Radius
      final double radiusMeters;
      if (customRadiusMeters != null) {
        radiusMeters = customRadiusMeters;
      } else {
        final radiusKm = CurrentUserStorage.getDiscoveryRadius();
        radiusMeters = radiusKm * 1000.0;
      }

      // 3. API Call
      final response = await _searchServices.visualSearch(
        imagePath: image.path,
        lat: lat,
        lon: lon,
        radius: radiusMeters,
      );
      if (response.isSuccess) {
        final results = response.products;
        final radiusUsed = response.radiusUsed ?? radiusMeters;
        final hasMoreBeyondRadius = response.hasMoreBeyondRadius;

        if (results.isNotEmpty) {
          results.sort(
            (a, b) => (b.visualScore ?? 0).compareTo(a.visualScore ?? 0),
          );
          emit(
            VisualSearchSuccess(
              results,
              radiusUsed: radiusUsed,
              hasMoreBeyondRadius: hasMoreBeyondRadius,
            ),
          );
        } else {
          emit(
            VisualSearchFailure(
              'No match within the selected radius.',
              radiusUsed: radiusUsed,
              hasMoreBeyondRadius: hasMoreBeyondRadius,
            ),
          );
        }
      } else {
        emit(VisualSearchFailure(response.message ?? 'Search failed'));
      }
    } catch (e) {
      emit(VisualSearchFailure(e.toString()));
    }
  }

  void reset() {
    emit(VisualSearchInitial());
  }

  /// Groups products by [productId] or [name] for deduplicated display.
  static Map<String, List<Product>> groupByProduct(List<Product> items) {
    final map = <String, List<Product>>{};
    for (final item in items) {
      final key = item.productId ?? item.name;
      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }
    return map;
  }
}
