import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/signup_cubit/signup_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/views/verification_code_screen.dart';
import 'package:nearvendorapp/views/screens/auth/widgets/auth_text_field_widget.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            AppNavigator.push(context, const VerificationCodeScreen());
          }
        },
        builder: (context, state) {
          final cubit = context.read<SignupCubit>();
          return LoadingScreenView(
            isLoading: state is SignupLoading,
            child: AppScaffold(
              body: Stack(
                children: [
                  Image.asset(Assets.images.itemsArt.path, fit: BoxFit.cover),
                  SafeArea(
                    child: Padding(
                      padding: AppSpacing.bottomNavigationPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.icons.nearVendorText.svg(),
                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),
                          Text(
                            'Create Account to get started',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),
                          Spacer(),
                          Form(
                            key: cubit.formKey,
                            child: Column(
                              children: [
                                AuthTextFieldWidget(
                                  label: 'email',
                                  controller: cubit.emailController,
                                ),
                                SizedBox(
                                  height: AppSpacing.smallVerticalSpacing(
                                    context,
                                  ),
                                ),
                                AuthTextFieldWidget(
                                  label: 'password',
                                  controller: cubit.passwordController,
                                ),
                                SizedBox(
                                  height: AppSpacing.smallVerticalSpacing(
                                    context,
                                  ),
                                ),

                                AuthTextFieldWidget(
                                  label: 'confirm password',
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
                                'Don\'t have an account? ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              TextButton(
                                onPressed: () {
                                  AppNavigator.pop(context);
                                },
                                child: Text(
                                  'Sign In',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: ColorName.secondary),
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
