import 'package:nearvendorapp/analytics/analytics_event.dart';

/// Local in-memory queue that holds [BuyerEventData] until they are
/// flushed to the backend by [AnalyticsController].
///
/// Auto-flush is triggered when the queue reaches [maxSize].
class AnalyticsBuffer {
  AnalyticsBuffer._();
  static final AnalyticsBuffer instance = AnalyticsBuffer._();

  static const int maxSize = 50;

  final List<BuyerEventData> _queue = [];

  void add(BuyerEventData event) => _queue.add(event);

  /// Returns all queued events and clears the buffer atomically.
  List<BuyerEventData> drainAll() {
    final snapshot = List<BuyerEventData>.from(_queue);
    _queue.clear();
    return snapshot;
  }

  bool get isEmpty => _queue.isEmpty;
  int get length => _queue.length;
  bool get isFull => _queue.length >= maxSize;
}
