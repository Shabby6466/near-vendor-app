import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_responses/analytics_response.dart';
import 'package:nearvendorapp/services/analytics_services.dart';

// States
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsSuccess extends AnalyticsState {
  final List<PortfolioEntry> portfolio;
  final ShopInsightsData? selectedShopInsights;
  final MarketInsightsData? selectedShopMarket;
  final List<AnalyticsStatEntry>? selectedShopStats;
  final String? selectedShopId;
  final int days;

  const AnalyticsSuccess({
    required this.portfolio,
    this.selectedShopInsights,
    this.selectedShopMarket,
    this.selectedShopStats,
    this.selectedShopId,
    this.days = 7,
  });

  AnalyticsSuccess copyWith({
    List<PortfolioEntry>? portfolio,
    ShopInsightsData? selectedShopInsights,
    MarketInsightsData? selectedShopMarket,
    List<AnalyticsStatEntry>? selectedShopStats,
    String? selectedShopId,
    int? days,
  }) {
    return AnalyticsSuccess(
      portfolio: portfolio ?? this.portfolio,
      selectedShopInsights: selectedShopInsights ?? this.selectedShopInsights,
      selectedShopMarket: selectedShopMarket ?? this.selectedShopMarket,
      selectedShopStats: selectedShopStats ?? this.selectedShopStats,
      selectedShopId: selectedShopId ?? this.selectedShopId,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [
    portfolio, 
    selectedShopInsights, 
    selectedShopMarket, 
    selectedShopStats,
    selectedShopId,
    days,
  ];
}

class AnalyticsFailure extends AnalyticsState {
  final String message;
  const AnalyticsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsServices _services = AnalyticsServices();

  AnalyticsCubit() : super(AnalyticsInitial());

  Future<void> fetchPortfolioAnalytics({int days = 7}) async {
    emit(AnalyticsLoading());
    try {
      final response = await _services.getVendorPortfolio(days: days);
      if (response.success) {
        emit(AnalyticsSuccess(portfolio: response.data, days: days));
      } else {
        emit(AnalyticsFailure('Failed to load portfolio stats'));
      }
    } catch (e) {
      emit(AnalyticsFailure(e.toString()));
    }
  }

  Future<void> fetchShopDetails(String shopId, {int days = 7}) async {
    final currentState = state;
    List<PortfolioEntry> portfolio = [];
    if (currentState is AnalyticsSuccess) {
      portfolio = currentState.portfolio;
      emit(currentState.copyWith(selectedShopId: shopId, days: days));
    } else {
      emit(AnalyticsLoading());
    }

    try {
      final results = await Future.wait([
        _services.getVendorShopInsights(shopId: shopId, days: days),
        _services.getMarketInsights(shopId: shopId, days: days),
        _services.getShopStats(shopId: shopId, days: days),
      ]);

      final insights = results[0] as ShopInsightsResponse;
      final market = results[1] as MarketInsightsResponse;
      final stats = results[2] as AnalyticsStatsResponse;

      if (state is AnalyticsSuccess) {
        emit((state as AnalyticsSuccess).copyWith(
          selectedShopInsights: insights.success ? insights.data : null,
          selectedShopMarket: market.success ? market.data : null,
          selectedShopStats: stats.success ? stats.data : null,
        ));
      } else {
        emit(AnalyticsSuccess(
          portfolio: portfolio,
          selectedShopId: shopId,
          selectedShopInsights: insights.success ? insights.data : null,
          selectedShopMarket: market.success ? market.data : null,
          selectedShopStats: stats.success ? stats.data : null,
          days: days,
        ));
      }
    } catch (e) {
      if (state is! AnalyticsSuccess) {
        emit(AnalyticsFailure(e.toString()));
      }
    }
  }
}
