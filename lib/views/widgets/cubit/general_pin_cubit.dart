import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'general_pin_state.dart';

class GeneralPinCubit extends Cubit<GeneralPinState> {
  GeneralPinCubit() : super(GeneralPinInitial());

  final codeController = TextEditingController();

  void onCodeChanged(String code) {
    emit(GeneralPinCodeChanged(code));
  }

  void submitCode(String code) {
    if (code.isNotEmpty) {
      emit(GeneralPinLoading());
    }
  }

  void onSuccess() {
    emit(GeneralPinSuccess());
  }

  void onFailure(String message) {
    emit(GeneralPinFailure(message));
  }

  @override
  Future<void> close() async {
    codeController.dispose();
    await super.close();
  }
}
