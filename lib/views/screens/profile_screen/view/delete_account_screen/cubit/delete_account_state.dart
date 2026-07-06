import 'package:equatable/equatable.dart';

enum DeleteAccountStatus { initial, submitting, success, failure }

class DeleteAccountState extends Equatable {
  final bool isConfirmed;
  final DeleteAccountStatus status;
  final String? errorMessage;

  const DeleteAccountState({
    this.isConfirmed = false,
    this.status = DeleteAccountStatus.initial,
    this.errorMessage,
  });

  DeleteAccountState copyWith({
    bool? isConfirmed,
    DeleteAccountStatus? status,
    String? errorMessage,
  }) {
    return DeleteAccountState(
      isConfirmed: isConfirmed ?? this.isConfirmed,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isConfirmed, status, errorMessage];
}
