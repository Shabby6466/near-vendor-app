import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

    // Request Location Permissions
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(SignupRequiresManualLocation());
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(SignupRequiresManualLocation());
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      emit(SignupRequiresManualLocation());
      return;
    }

    double lat = 0.0;
    double lng = 0.0;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      lat = position.latitude;
      lng = position.longitude;
    } catch (e) {
      emit(SignupRequiresManualLocation());
      return;
    }

    await _submitSignup(lat, lng);
  }

  Future<void> handleSignupWithLocation(double lat, double lng) async {
    emit(SignupLoading());
    await _submitSignup(lat, lng);
  }

  Future<void> _submitSignup(double lat, double lng) async {
    final response = await AuthServices().createUser(
      CreateUserInput(
        fullName: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        latitude: lat,
        longitude: lng,
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
