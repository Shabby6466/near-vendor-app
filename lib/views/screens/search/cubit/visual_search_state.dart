part of 'visual_search_cubit.dart';

sealed class VisualSearchState extends Equatable {
  const VisualSearchState();

  @override
  List<Object?> get props => [];
}

final class VisualSearchInitial extends VisualSearchState {}

final class VisualSearchLoading extends VisualSearchState {}

final class VisualSearchSuccess extends VisualSearchState {
  final List<Item> results;

  const VisualSearchSuccess(this.results);

  @override
  List<Object?> get props => [results];
}

final class VisualSearchFailure extends VisualSearchState {
  final String message;

  const VisualSearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}
