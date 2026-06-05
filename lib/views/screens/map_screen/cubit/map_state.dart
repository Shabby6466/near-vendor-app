import 'package:equatable/equatable.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapSuccess extends MapState {}

class MapFailure extends MapState {
  final String message;
  const MapFailure(this.message);

  @override
  List<Object?> get props => [message];
}
