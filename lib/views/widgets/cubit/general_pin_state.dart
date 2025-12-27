part of 'general_pin_cubit.dart';

sealed class GeneralPinState extends Equatable {
  const GeneralPinState();

  @override
  List<Object?> get props => [];
}

final class GeneralPinInitial extends GeneralPinState {}

final class GeneralPinCodeChanged extends GeneralPinState {
  final String code;

  const GeneralPinCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

final class GeneralPinLoading extends GeneralPinState {}

final class GeneralPinSuccess extends GeneralPinState {}

final class GeneralPinFailure extends GeneralPinState {
  final String message;

  const GeneralPinFailure(this.message);

  @override
  List<Object?> get props => [message];
}
