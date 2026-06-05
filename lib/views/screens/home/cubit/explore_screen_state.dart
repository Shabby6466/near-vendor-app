part of 'explore_screen_cubit.dart';

sealed class ExploreScreenState extends Equatable {
  const ExploreScreenState();

  @override
  List<Object?> get props => [];
}

final class ExploreScreenInitial extends ExploreScreenState {}

final class ExploreScreenLoading extends ExploreScreenState {
  final int timestamp;
  const ExploreScreenLoading({required this.timestamp});

  @override
  List<Object?> get props => [timestamp];
}

final class ExploreScreenSuccess extends ExploreScreenState {
  final int timestamp;
  const ExploreScreenSuccess({required this.timestamp});

  @override
  List<Object?> get props => [timestamp];
}

final class ExploreScreenFailure extends ExploreScreenState {
  final String message;
  const ExploreScreenFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ExploreScreenNoLocation extends ExploreScreenState {
  final String message;
  const ExploreScreenNoLocation({
    this.message = 'Location not found. Please set it manually.',
  });

  @override
  List<Object?> get props => [message];
}
