import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/enums/report_target_type.dart';
import 'package:nearvendorapp/services/safety_services.dart';

part 'safety_report_state.dart';

class SafetyReportCubit extends Cubit<SafetyReportState> {
  final String targetId;
  final ReportTargetType targetType;

  SafetyReportCubit({
    required this.targetId,
    required this.targetType,
  }) : super(const SafetyReportInitial());

  final detailsController = TextEditingController();

  final List<String> reasons = const [
    'Inappropriate Content',
    'Spam or Misleading',
    'Harassment',
    'Offensive Imagery',
    'Illegal Goods',
    'Other',
  ];

  void selectReason(String? reason) {
    emit(SafetyReportInitial(selectedReason: reason));
  }

  Future<void> submitReport() async {
    final currentReason = state.selectedReason;
    if (currentReason == null) return;

    if (currentReason == 'Other' && detailsController.text.trim().isEmpty) {
      emit(SafetyReportFailure('Please specify the reason.', selectedReason: currentReason));
      return;
    }

    emit(SafetyReportLoading(selectedReason: currentReason));
    try {
      final String reasonPayload = currentReason == 'Other'
          ? detailsController.text.trim()
          : currentReason;
      
      final String? additionalDetailsPayload = currentReason == 'Other'
          ? null
          : (detailsController.text.trim().isEmpty ? null : detailsController.text.trim());

      final result = await SafetyServices().reportContent(
        targetId: targetId,
        targetType: targetType,
        reason: reasonPayload,
        additionalDetails: additionalDetailsPayload,
      );

      if (result.success == true) {
        emit(SafetyReportSuccess(selectedReason: currentReason));
      } else {
        emit(SafetyReportFailure(result.message ?? 'Failed to submit report', selectedReason: currentReason));
      }
    } catch (e) {
      emit(SafetyReportFailure(e.toString(), selectedReason: currentReason));
    }
  }

  @override
  Future<void> close() {
    detailsController.dispose();
    return super.close();
  }
}
