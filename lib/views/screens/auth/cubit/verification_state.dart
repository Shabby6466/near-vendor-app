part of 'verification_cubit.dart';

sealed class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

final class VerificationInitial extends VerificationState {}

final class VerificationLoading extends VerificationState {}

/// Emitted on each keystroke so the view can enable/disable the CTA button.
final class VerificationCodeChanged extends VerificationState {
  final String code;
  const VerificationCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

/// OTP verified — carries the [User] so the view's BlocListener can call
/// SessionCubit.setAuthenticated(state.user) and navigate.
final class VerificationSuccess extends VerificationState {
  final User? user;
  const VerificationSuccess({this.user});

  @override
  List<Object?> get props => [user];
}

/// Generic network or server error.
final class VerificationFailure extends VerificationState {
  final String message;
  const VerificationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
