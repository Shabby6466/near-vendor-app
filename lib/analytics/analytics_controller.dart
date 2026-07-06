import 'dart:async';
import 'package:nearvendorapp/analytics/analytics_buffer.dart';
import 'package:nearvendorapp/analytics/analytics_event.dart';
import 'package:nearvendorapp/services/analytics_services.dart';

/// Centralized analytics controller for the buyer app.
///
/// Operates on a buffering mechanism: events are pushed to an in-memory
/// queue and flushed to the network either periodically or when the buffer fills.
class AnalyticsController {
  AnalyticsController._();
  static final AnalyticsController instance = AnalyticsController._();

  final AnalyticsBuffer _buffer = AnalyticsBuffer.instance;
  final AnalyticsServices _service = AnalyticsServices();

  Timer? _flushTimer;

  /// Starts the periodic flush timer (e.g. every 10 seconds).
  void initialize() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 10), (_) => _flush());
  }

  void dispose() {
    _flushTimer?.cancel();
    _flush();
  }

  /// Records an event to the local buffer.
  /// This method is entirely synchronous and safe to call anywhere — it
  /// can never crash or block the UI.
  void recordEvent(
    BuyerAnalyticsEvent event, {
    required String targetId,
    Map<String, dynamic> data = const {},
  }) {
    try {
      _buffer.add(BuyerEventData(
        event: event,
        targetId: targetId,
        data: data,
        recordedAt: DateTime.now(),
      ));

      // Eagerly flush when the buffer is full
      if (_buffer.isFull) _flush();
    } catch (_) {
      // Analytics must never crash the app
    }
  }

  /// Force-flush the buffer (e.g. when the app goes to background).
  Future<void> flush() => _flush();

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;
    final events = _buffer.drainAll();
    try {
      await _service.trackBatch(events);
    } catch (_) {
      // Silently drop — events are already drained from buffer.
    }
  }
}
