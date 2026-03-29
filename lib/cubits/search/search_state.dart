part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> recentSearches;
  final List<Item> recentItems;

  const SearchInitial({
    this.recentSearches = const [],
    this.recentItems = const [],
  });

  @override
  List<Object?> get props => [recentSearches, recentItems];
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuccess extends SearchState {
  final List<Item> items;
  final SearchMeta? meta;
  final String? message;

  const SearchSuccess({
    required this.items,
    this.meta,
    this.message,
  });

  @override
  List<Object?> get props => [items, meta, message];
}

class SearchFailure extends SearchState {
  final String message;

  const SearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}
