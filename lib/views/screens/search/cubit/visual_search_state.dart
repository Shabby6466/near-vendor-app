part of 'visual_search_cubit.dart';

abstract class VisualSearchState extends Equatable {
  const VisualSearchState();

  @override
  List<Object?> get props => [];
}

class VisualSearchInitial extends VisualSearchState {}

class VisualSearchLoading extends VisualSearchState {}

class VisualSearchSuccess extends VisualSearchState {
  final List<Item> results;

  const VisualSearchSuccess(this.results);

  @override
  List<Object?> get props => [results];
}

class VisualSearchFailure extends VisualSearchState {
  final String message;

  const VisualSearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}
