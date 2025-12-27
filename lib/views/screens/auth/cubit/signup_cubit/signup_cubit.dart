import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> handleSignup() async {
    emit(SignupLoading());
    Future.delayed(Duration(seconds: 2), () {
      emit(SignupSuccess());
    });
  }

  @override
  Future<void> close() async {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    await super.close();
  }
}
