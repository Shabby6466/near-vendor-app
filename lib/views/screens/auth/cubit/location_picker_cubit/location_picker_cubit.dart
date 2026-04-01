import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/services/location_service.dart';

part 'location_picker_state.dart';

class LocationPickerCubit extends Cubit<LocationPickerState> {
  final LocationService _locationService = LocationService();

  LocationPickerCubit({LatLng? initialLocation})
      : super(LocationPickerState(
          selectedLocation: initialLocation ?? const LatLng(33.667306, 73.075177),
        ));

  void updateLocation(LatLng location) {
    emit(state.copyWith(selectedLocation: location));
  }

  Future<void> searchLocation(String query) async {
    if (query.length < 3) {
      emit(state.copyWith(suggestions: []));
      return;
    }

    emit(state.copyWith(isSearching: true));
    try {
      final suggestions = await _locationService.getSuggestions(query);
      emit(state.copyWith(suggestions: suggestions, isSearching: false));
    } catch (e) {
      emit(state.copyWith(isSearching: false));
    }
  }

  void selectSuggestion(LocationSuggestion suggestion) {
    emit(state.copyWith(
      selectedLocation: suggestion.location,
      suggestions: [],
    ));
  }

  void confirmLocation() {
    emit(state.copyWith(status: LocationPickerStatus.confirmed));
  }
}

// Removed redundant classes that are now in location_picker_state.dart
