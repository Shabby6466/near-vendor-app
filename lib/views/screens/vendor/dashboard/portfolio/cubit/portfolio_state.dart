import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioSuccess extends PortfolioState {
  final List<Shop> shops;
  final List<Item> items;
  final List<Item> bestPerformers;
  final List<Item> poorPerformers;
  final String? searchQuery;
  final int days;

  const PortfolioSuccess({
    required this.shops,
    required this.items,
    required this.bestPerformers,
    required this.poorPerformers,
    this.searchQuery,
    this.days = 7,
  });

  PortfolioSuccess copyWith({
    List<Shop>? shops,
    List<Item>? items,
    List<Item>? bestPerformers,
    List<Item>? poorPerformers,
    String? searchQuery,
    int? days,
  }) {
    return PortfolioSuccess(
      shops: shops ?? this.shops,
      items: items ?? this.items,
      bestPerformers: bestPerformers ?? this.bestPerformers,
      poorPerformers: poorPerformers ?? this.poorPerformers,
      searchQuery: searchQuery ?? this.searchQuery,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [shops, items, bestPerformers, poorPerformers, searchQuery, days];
}

class PortfolioFailure extends PortfolioState {
  final String message;
  const PortfolioFailure(this.message);

  @override
  List<Object?> get props => [message];
}
