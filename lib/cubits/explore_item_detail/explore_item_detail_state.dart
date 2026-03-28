import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';

abstract class ExploreItemDetailState extends Equatable {
  const ExploreItemDetailState();

  @override
  List<Object?> get props => [];
}

class ExploreItemDetailInitial extends ExploreItemDetailState {}

class ExploreItemDetailLoading extends ExploreItemDetailState {}

class ExploreItemDetailSuccess extends ExploreItemDetailState {
  final Item item;
  final Shop shop;

  const ExploreItemDetailSuccess(this.item, this.shop);

  @override
  List<Object?> get props => [item, shop];
}

class ExploreItemDetailFailure extends ExploreItemDetailState {
  final String message;

  const ExploreItemDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
