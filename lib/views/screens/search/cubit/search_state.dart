part of 'search_cubit.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  final List<String> recentSearches;
  final List<Product> recentItems;

  const SearchInitial({
    this.recentSearches = const [],
    this.recentItems = const [],
  });

  @override
  List<Object?> get props => [recentSearches, recentItems];
}

final class SearchLoading extends SearchState {}

final class SearchSuccess extends SearchState {
  final List<Product> items;
  final SearchMeta? meta;
  final String? message;
  final String? query;
  final bool isGlobalFallback;
  final String? rangeMessage;

  const SearchSuccess({
    required this.items,
    this.meta,
    this.message,
    this.query,
    this.isGlobalFallback = false,
    this.rangeMessage,
  });

  @override
  List<Object?> get props => [
    items,
    meta,
    message,
    query,
    isGlobalFallback,
    rangeMessage,
  ];
}

final class SearchFailure extends SearchState {
  final String message;

  const SearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}
