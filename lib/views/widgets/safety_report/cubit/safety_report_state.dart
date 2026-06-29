part of 'safety_report_cubit.dart';

sealed class SafetyReportState extends Equatable {
  final String? selectedReason;
  const SafetyReportState({this.selectedReason});

  @override
  List<Object?> get props => [selectedReason];
}

final class SafetyReportInitial extends SafetyReportState {
  const SafetyReportInitial({super.selectedReason});
}

final class SafetyReportLoading extends SafetyReportState {
  const SafetyReportLoading({super.selectedReason});
}

final class SafetyReportSuccess extends SafetyReportState {
  const SafetyReportSuccess({super.selectedReason});
}

final class SafetyReportFailure extends SafetyReportState {
  final String message;
  const SafetyReportFailure(this.message, {super.selectedReason});

  @override
  List<Object?> get props => [message, selectedReason];
}
