import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/login_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/view/sign_up_screen.dart';
import 'package:nearvendorapp/views/screens/forgot_password/view/forgot_password_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            AppNavigator.pushAndRemoveUntil(context, const MainScreen());
          } else if (state is LoginFailure) {
            AppAlerts.showError(context, state.message, isDarkBackground: true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          final theme = Theme.of(context);

          return LoadingScreenView(
            isLoading: state is LoginLoading,
            child: AuthScaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: AppSpacing.bottomNavigationPadding(
                    context,
                  ).copyWith(left: 24, right: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AppAnimateList.stagger([
                          SizedBox(
                            height: AppSpacing.extraLargeVerticalSpacing(
                              context,
                            ),
                          ),

                          Assets.icons.nearVendorText.svg(
                            height: 32,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),

                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),

                          Text(
                            'What ever is near you,\nNearvendor is the nearest',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(
                            height: AppSpacing.smallVerticalSpacing(context),
                          ),
                          Text(
                            'Discover millions of specialized items right in your local neighborhood.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: AppAnimateList.stagger([
                          SizedBox(
                            height:
                                AppSpacing.extraLargeVerticalSpacing(context) *
                                3,
                          ),

                          Form(
                            key: cubit.formKey,
                            child: Column(
                              children: AppAnimateList.stagger([
                                AppTextField(
                                  hint: 'Email',
                                  controller: cubit.emailController,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  keyboardType: TextInputType.emailAddress,
                                  validator:
                                      TextFieldValidators.emailFieldValidation,
                                ),

                                SizedBox(
                                  height: AppSpacing.mediumVerticalSpacing(
                                    context,
                                  ),
                                ),

                                AppTextField(
                                  hint: 'Password',
                                  isPassword: true,
                                  controller: cubit.passwordController,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  validator: TextFieldValidators
                                      .passwordFieldValidator,
                                ),

                                SizedBox(
                                  height: AppSpacing.smallVerticalSpacing(
                                    context,
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      AppNavigator.push(
                                        context,
                                        const ForgotPasswordScreen(),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),

                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),

                          AppElevatedButton(
                            onPressed: cubit.handleSignin,
                            text: 'Continue',
                            color: theme.colorScheme.secondary,
                          ),

                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  AppNavigator.pushReplacement(
                                    context,
                                    const SignUpScreen(),
                                  );
                                },
                                child: Text(
                                  'Sign up',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
