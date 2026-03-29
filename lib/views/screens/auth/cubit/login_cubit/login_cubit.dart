import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';


part 'login_state.dart';


class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> handleSignin() async {
    emit(LoginLoading());
    final response = await AuthServices().login(
      LoginInput(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );
 print('response -> $response');
    if (response.status == 200 || response.status == 201) {
      if (response.user != null && response.token != null) {
        await CurrentUserStorage.storeUserData(response.user);
        await CurrentUserStorage.storeUserAuthToken(response.token!, null);
        
        // Sync last known location to server upon login
        final lastLocation = CurrentUserStorage.getLastLocation();
        if (lastLocation != null) {
          AuthServices().updateUserLocation(
            lastLocation['lat']!,
            lastLocation['lon']!,
          );
        }
      }
      emit(LoginSuccess(user: response.user));
    } else {
      emit(LoginFailure(response.message ?? 'Login failed'));
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
