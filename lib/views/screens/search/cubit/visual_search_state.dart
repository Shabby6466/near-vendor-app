part of 'visual_search_cubit.dart';

sealed class VisualSearchState extends Equatable {
  const VisualSearchState();

  @override
  List<Object?> get props => [];
}

final class VisualSearchInitial extends VisualSearchState {}

final class VisualSearchLoading extends VisualSearchState {}

final class VisualSearchSuccess extends VisualSearchState {
  final List<Product> results;
  final double? radiusUsed;
  final bool hasMoreBeyondRadius;

  const VisualSearchSuccess(
    this.results, {
    this.radiusUsed,
    this.hasMoreBeyondRadius = false,
  });

  @override
  List<Object?> get props => [results, radiusUsed, hasMoreBeyondRadius];
}

final class VisualSearchFailure extends VisualSearchState {
  final String message;
  final double? radiusUsed;
  final bool hasMoreBeyondRadius;

  const VisualSearchFailure(
    this.message, {
    this.radiusUsed,
    this.hasMoreBeyondRadius = false,
  });

  @override
  List<Object?> get props => [message, radiusUsed, hasMoreBeyondRadius];
}
