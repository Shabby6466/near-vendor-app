import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/signup_cubit/signup_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/views/verification_code_screen.dart';
import 'package:nearvendorapp/views/screens/auth/widgets/auth_text_field_widget.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/views/screens/auth/views/location_picker_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => SignupCubit(),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) async {
          if (state is SignupRequiresManualLocation) {
            final LatLng? result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
            );
            if (result != null) {
              context.read<SignupCubit>().handleSignupWithLocation(result.latitude, result.longitude);
            }
          }
          if (state is SignupSuccess) {
            AppNavigator.push(
              context,
              VerificationCodeScreen(email: state.email),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<SignupCubit>();
          return LoadingScreenView(
            isLoading: state is SignupLoading,
            child: AppScaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    Assets.images.itemsArt.path, 
                    fit: BoxFit.cover,
                    color: isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: AppSpacing.bottomNavigationPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.icons.nearVendorText.svg(
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),
                          Text(
                            'Create Account to get started',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: AppSpacing.extraLargeVerticalSpacing(context),
                          ),
                          Form(
                            key: cubit.formKey,
                            child: Column(
                              children: [
                                AuthTextFieldWidget(
                                  label: 'full name',
                                  controller: cubit.fullNameController,
                                ),
                                SizedBox(
                                  height: AppSpacing.smallVerticalSpacing(context),
                                ),
                                AuthTextFieldWidget(
                                  label: 'email',
                                  controller: cubit.emailController,
                                ),
                                SizedBox(
                                  height: AppSpacing.smallVerticalSpacing(context),
                                ),
                                AuthTextFieldWidget(
                                  label: 'password',
                                  isPassword: true,
                                  controller: cubit.passwordController,
                                ),
                                SizedBox(
                                  height: AppSpacing.smallVerticalSpacing(context),
                                ),
                                AuthTextFieldWidget(
                                  label: 'confirm password',
                                  isPassword: true,
                                  controller: cubit.confirmPasswordController,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),
                          AppElevatedButton(
                            onPressed: () {
                              cubit.handleSignup();
                            },
                            isEnabled: true,
                            text: 'continue',
                          ),
                          SizedBox(
                            height: AppSpacing.smallVerticalSpacing(context),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  AppNavigator.pop(context);
                                },
                                child: Text(
                                  'Sign In',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
