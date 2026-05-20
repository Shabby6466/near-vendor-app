part of 'signup_cubit.dart';

sealed class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupSuccess extends SignupState {
  const SignupSuccess(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

final class SignupFailure extends SignupState {
  const SignupFailure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

final class SignupRequiresManualLocation extends SignupState {}
