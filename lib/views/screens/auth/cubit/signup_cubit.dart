import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final _authServices = AuthServices();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> handleSignup() async {
    // Validate form before doing anything — matches vendor_app reference pattern
    if (!formKey.currentState!.validate()) return;

    emit(SignupLoading());

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(SignupRequiresManualLocation());
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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

    try {
      // Use non-deprecated LocationSettings API
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await _submitSignup(position.latitude, position.longitude);
    } catch (e) {
      emit(SignupRequiresManualLocation());
    }
  }

  Future<void> handleSignupWithLocation(double lat, double lng) async {
    // Called after the user manually picks a location — still validate the form
    if (!formKey.currentState!.validate()) return;
    emit(SignupLoading());
    await _submitSignup(lat, lng);
  }

  Future<void> _submitSignup(double lat, double lng) async {
    try {
      final response = await _authServices.createUser(
        CreateUserInput(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          latitude: lat,
          longitude: lng,
          role: UserRoles.buyer,
        ),
      );

      if (response.status == 200 || response.status == 201) {
        if (response.user != null && response.token != null) {
          await AppData().setUser(
            response.user,
            token: response.token,
            refreshToken: response.refreshToken,
          );
        }
        // Emit success with the email so the view can navigate to OTP screen.
        // SessionCubit.setAuthenticated() is called by the view's BlocListener
        // after OTP verification — not here — so we don't need navigatorKey.
        emit(SignupSuccess(emailController.text.trim()));
      } else {
        emit(SignupFailure(response.message ?? 'Signup failed'));
      }
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    emailController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    await super.close();
  }
}
