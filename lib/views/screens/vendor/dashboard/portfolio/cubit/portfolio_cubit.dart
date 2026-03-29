import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/portfolio_services.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/portfolio/cubit/portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioServices _portfolioServices = PortfolioServices();

  PortfolioCubit() : super(PortfolioInitial()) {
    loadPortfolio();
  }

  Future<void> loadPortfolio({int days = 7}) async {
    final currentState = state;
    if (currentState is! PortfolioSuccess) {
      emit(PortfolioLoading());
    }

    try {
      final performanceResponse = await _portfolioServices.getPerformance(days: days);
      
      if (performanceResponse.success) {
        if (state is PortfolioSuccess) {
          emit((state as PortfolioSuccess).copyWith(
            bestPerformers: performanceResponse.bestPerformers,
            poorPerformers: performanceResponse.poorPerformers,
            days: days,
          ));
        } else {
          emit(PortfolioSuccess(
            shops: const [],
            items: const [],
            bestPerformers: performanceResponse.bestPerformers,
            poorPerformers: performanceResponse.poorPerformers,
            days: days,
          ));
        }
      } else {
        emit(PortfolioFailure(performanceResponse.message));
      }
    } catch (e) {
      emit(PortfolioFailure(e.toString()));
    }
  }

  Future<void> searchPortfolio(String query) async {
    if (query.isEmpty) {
      if (state is PortfolioSuccess) {
        emit((state as PortfolioSuccess).copyWith(shops: [], items: [], searchQuery: null));
      }
      return;
    }

    try {
      final response = await _portfolioServices.searchPortfolio(query: query);
      if (response.success) {
        if (state is PortfolioSuccess) {
          emit((state as PortfolioSuccess).copyWith(
            shops: response.shops,
            items: response.items,
            searchQuery: query,
          ));
        } else {
          emit(PortfolioSuccess(
            shops: response.shops,
            items: response.items,
            bestPerformers: const [],
            poorPerformers: const [],
            searchQuery: query,
          ));
        }
      }
    } catch (e) {
      // Keep existing state on search error
    }
  }

  void changeTimeRange(int days) {
    loadPortfolio(days: days);
  }
}
