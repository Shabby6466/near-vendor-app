import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { connected, disconnected, loading }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  ConnectivityCubit() : super(ConnectivityStatus.loading) {
    _init();
  }

  void _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      emit(ConnectivityStatus.disconnected);
    } else {
      emit(ConnectivityStatus.connected);
    }
  }

  Future<void> retry() async {
    emit(ConnectivityStatus.loading);
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
