enum WishlistStatus {
  pending('PENDING'),
  fulfilled('FULFILLED');

  const WishlistStatus(this.value);
  final String value;

  static WishlistStatus fromValue(String? v) {
    if (v == null) return WishlistStatus.pending;
    return WishlistStatus.values.firstWhere(
      (s) => s.value.toUpperCase() == v.toUpperCase(),
      orElse: () => WishlistStatus.pending,
    );
  }
}
