import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/services/search_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'visual_search_state.dart';

class VisualSearchCubit extends Cubit<VisualSearchState> {
  final SearchServices _searchServices = SearchServices();

  VisualSearchCubit() : super(VisualSearchInitial());

  Future<void> searchByImage(File image) async {
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

      // 2. Get Radius from Local Storage (defaults to 10km if not set)
      final radiusKm = CurrentUserStorage.getDiscoveryRadius();
      final radiusMeters = radiusKm * 1000;

      // 3. API Call
      final results = await _searchServices.visualSearch(
        imagePath: image.path,
        lat: position.latitude,
        lon: position.longitude,
        radius: radiusMeters,
      );

      if (results.isNotEmpty) {
        results.sort(
          (a, b) => (b.visualScore ?? 0).compareTo(a.visualScore ?? 0),
        );
        emit(VisualSearchSuccess(results));
      } else {
        emit(const VisualSearchFailure('No matching products found nearby.'));
      }
    } catch (e) {
      emit(VisualSearchFailure('Search failed: ${e.toString()}'));
    }
  }

  void reset() {
    emit(VisualSearchInitial());
  }
}
