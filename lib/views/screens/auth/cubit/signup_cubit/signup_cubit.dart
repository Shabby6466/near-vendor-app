import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> handleSignup() async {
    emit(SignupLoading());
    final response = await AuthServices().createUser(
      CreateUserInput(
        fullName: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        latitude: 44.4,
        longitude: 44.4,
        role: UserRoles.BUYER,
      ),
    );
    print('response --> ${response.toJson()}');
    if (response.status == 200 || response.status == 201) {
      emit(SignupSuccess(emailController.text));
    } else {
      // Handle error or other states if needed
    }
  }

  @override
  Future<void> close() async {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    await super.close();
  }
}
