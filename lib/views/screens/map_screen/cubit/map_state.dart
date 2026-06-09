import 'package:equatable/equatable.dart';

abstract class MapState extends Equatable {
  static int _counter = 0;
  final int _stateId;

  MapState() : _stateId = _counter++;

  @override
  List<Object?> get props => [_stateId];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapSuccess extends MapState {}

class MapFailure extends MapState {
  final String message;
  MapFailure(this.message);

  @override
  List<Object?> get props => [message, _stateId];
}
