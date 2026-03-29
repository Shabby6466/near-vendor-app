part of 'vendor_demand_cubit.dart';

abstract class VendorDemandState extends Equatable {
  const VendorDemandState();

  @override
  List<Object> get props => [];
}

class VendorDemandInitial extends VendorDemandState {}

class VendorDemandLoading extends VendorDemandState {}

class VendorDemandLoaded extends VendorDemandState {
  final List<WishlistItem> demands;

  const VendorDemandLoaded({required this.demands});

  @override
  List<Object> get props => [demands];
}

class VendorDemandError extends VendorDemandState {
  final String message;

  const VendorDemandError({required this.message});

  @override
  List<Object> get props => [message];
}
