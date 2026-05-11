part of 'vendor_demand_cubit.dart';

sealed class VendorDemandState extends Equatable {
  const VendorDemandState();

  @override
  List<Object> get props => [];
}

final class VendorDemandInitial extends VendorDemandState {}

final class VendorDemandLoading extends VendorDemandState {}

final class VendorDemandLoaded extends VendorDemandState {
  final List<WishlistItem> demands;

  const VendorDemandLoaded({required this.demands});

  @override
  List<Object> get props => [demands];
}

final class VendorDemandError extends VendorDemandState {
  final String message;

  const VendorDemandError({required this.message});

  @override
  List<Object> get props => [message];
}
