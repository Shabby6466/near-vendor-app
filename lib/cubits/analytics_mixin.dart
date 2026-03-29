import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/analytics_services.dart';

mixin AnalyticsMixin<S> on Cubit<S> {
  final AnalyticsServices _analyticsServices = AnalyticsServices();
  
  final Set<String> _pendingImpressions = {};
  final Set<String> _sentImpressions = {};
  Timer? _analyticsTimer;
  String? _analyticsSource;
  final Map<String, dynamic> _extraMetadata = {};

  void initAnalytics(String source) {
    _analyticsSource = source;
    _startAnalyticsTimer();
  }

  void updateAnalyticsMetadata(Map<String, dynamic> metadata) {
    _extraMetadata.addAll(metadata);
  }

  void _startAnalyticsTimer() {
    _analyticsTimer?.cancel();
    _analyticsTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendBatchAnalytics();
    });
  }

  void trackImpression(String id) {
    if (_sentImpressions.contains(id) || _pendingImpressions.contains(id)) {
      return;
    }
    _pendingImpressions.add(id);
    if (_pendingImpressions.length >= 10) {
      _sendBatchAnalytics();
    }
  }

  Future<void> _sendBatchAnalytics() async {
    if (_pendingImpressions.isEmpty) return;

    final targetIds = _pendingImpressions.toList();
    _sentImpressions.addAll(targetIds);
    _pendingImpressions.clear();

    await _analyticsServices.sendBatchAnalytics(
      targetIds: targetIds,
      eventType: 'IMPRESSION',
      metadata: {
        'source': _analyticsSource ?? 'unknown',
        ..._extraMetadata,
      },
    );
  }

  Future<void> closeAnalytics() async {
    _analyticsTimer?.cancel();
    await _sendBatchAnalytics();
  }
}
