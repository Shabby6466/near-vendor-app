import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final _authServices = AuthServices();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleSignin() async {
    // Validate form before hitting the API — matches vendor_app reference pattern
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());
    try {
      final response = await _authServices.login(
        LoginInput(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        ),
      );

      if (response.status == 200 || response.status == 201) {
        if (response.user != null && response.token != null) {
          await AppData().setUser(
            response.user,
            token: response.token,
            refreshToken: response.refreshToken,
          );

          // Sync last known location to server upon login (fire-and-forget)
          final lastLocation = CurrentUserStorage.getLastLocation();
          if (lastLocation != null) {
            _authServices.updateUserLocation(
              lastLocation['lat']!,
              lastLocation['lon']!,
            );
          }
        }
        emit(LoginSuccess(user: response.user));
      } else {
        emit(LoginFailure(response.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
