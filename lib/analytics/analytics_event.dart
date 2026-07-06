/// Every event the buyer app can record.
///
/// [backendValue] mirrors the backend `AnalyticsEventType` enum exactly —
/// this is the string sent over the wire.
///
/// To add a new event: add one entry here. Nothing else needs to change.
enum BuyerAnalyticsEvent {
  // ── Shop-level ────────────────────────────────────────────────────────────
  shopImpression('IMPRESSION'),
  shopViewed('VIEW'),

  // ── Item-level ────────────────────────────────────────────────────────────
  itemImpression('ITEM_IMPRESSION'),
  itemViewed('ITEM_VIEW'),

  // ── Engagement ────────────────────────────────────────────────────────────
  wishlistAdded('WISHLIST_ADD'),
  contactTapped('CONTACT_TAP'),
  chatTapped('CHAT_TAP'),
  callTapped('CALL_TAP'),
  shareTriggered('SHARE'),
  directionsRequested('SHOP_DIRECTION'),

  // ── Search ────────────────────────────────────────────────────────────────
  searchPerformed('SEARCH'),
  visualSearchPerformed('VISUAL_SEARCH');

  const BuyerAnalyticsEvent(this.backendValue);

  /// The event type string sent to the backend analytics batch endpoint.
  final String backendValue;
}

/// A single event payload ready to be buffered and flushed to the backend.
class BuyerEventData {
  final BuyerAnalyticsEvent event;
  final String targetId;
  final Map<String, dynamic> data;
  final DateTime recordedAt;

  const BuyerEventData({
    required this.event,
    required this.targetId,
    this.data = const {},
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        'eventType': event.backendValue,
        'targetId': targetId,
        'metadata': data,
      };
}
