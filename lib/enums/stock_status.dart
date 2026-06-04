enum StockStatus {
  available('available'),
  outOfStock('out_of_stock'),
  discontinued('discontinued');

  const StockStatus(this.value);
  final String value;

  static StockStatus? fromValue(String? v) {
    if (v == null) return null;
    for (final s in values) {
      if (s.value.toLowerCase() == v.toLowerCase()) return s;
    }
    return null;
  }

  String get label {
    switch (this) {
      case StockStatus.available:
        return 'Available';
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.discontinued:
        return 'Discontinued';
    }
  }
}
