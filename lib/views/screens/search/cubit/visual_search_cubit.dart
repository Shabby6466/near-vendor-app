import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/services/search_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'visual_search_state.dart';

class VisualSearchCubit extends Cubit<VisualSearchState> {
  final SearchServices _searchServices = SearchServices();

  VisualSearchCubit() : super(VisualSearchInitial());

  Future<void> searchByImage(File image, {double? customRadiusMeters}) async {
    emit(VisualSearchLoading());

    try {
      // 1. Get and Track location
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const VisualSearchFailure('Location services are disabled.'));
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const VisualSearchFailure('Location permissions are denied.'));
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();

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
        lat: position.latitude,
        lon: position.longitude,
        radius: radiusMeters,
      );
      final results = response.items;
      final radiusUsed = response.radiusUsed ?? radiusMeters;
      final hasMoreBeyondRadius = response.hasMoreBeyondRadius;

      if (results.isNotEmpty) {
        results.sort(
          (a, b) => (b.visualScore ?? 0).compareTo(a.visualScore ?? 0),
        );
        emit(VisualSearchSuccess(
          results,
          radiusUsed: radiusUsed,
          hasMoreBeyondRadius: hasMoreBeyondRadius,
        ));
      } else {
        emit(VisualSearchFailure(
          'No matching products found nearby.',
          radiusUsed: radiusUsed,
          hasMoreBeyondRadius: hasMoreBeyondRadius,
        ));
      }
    } catch (e) {
      emit(VisualSearchFailure('Search failed: $e'));
    }
  }

  void reset() {
    emit(VisualSearchInitial());
  }
}
