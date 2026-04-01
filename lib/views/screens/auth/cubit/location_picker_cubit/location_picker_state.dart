part of 'location_picker_cubit.dart';

enum LocationPickerStatus { initial, confirmed }

class LocationPickerState extends Equatable {
  final LatLng selectedLocation;
  final List<LocationSuggestion> suggestions;
  final bool isSearching;
  final LocationPickerStatus status;

  const LocationPickerState({
    required this.selectedLocation,
    this.suggestions = const [],
    this.isSearching = false,
    this.status = LocationPickerStatus.initial,
  });

  LocationPickerState copyWith({
    LatLng? selectedLocation,
    List<LocationSuggestion>? suggestions,
    bool? isSearching,
    LocationPickerStatus? status,
  }) {
    return LocationPickerState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      suggestions: suggestions ?? this.suggestions,
      isSearching: isSearching ?? this.isSearching,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [selectedLocation, suggestions, isSearching, status];
}
