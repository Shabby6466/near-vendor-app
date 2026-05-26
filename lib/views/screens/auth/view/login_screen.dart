import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/services/app_location_service.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/theme/app_theme_data.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/login_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/view/sign_up_screen.dart';
import 'package:nearvendorapp/views/screens/auth/widgets/auth_text_field_widget.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
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
            context.read<SessionCubit>().setAuthenticated(state.user);
            AppLocationService.instance.updateFromGps();
            AppNavigator.pushAndRemoveUntil(context, const MainScreen());
          } else if (state is LoginFailure) {
            AppAlerts.showError(context, state.message, isDarkBackground: true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          return Theme(
            data: AppThemeData.normalDarkTheme,
            child: LoadingScreenView(
              isLoading: state is LoginLoading,
              child: AuthScaffold(
                resizeToAvoidBottomInset: false,
                body: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final theme = Theme.of(context);
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: AppSpacing.bottomNavigationPadding(
                          context,
                        ).copyWith(left: 24, right: 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight -
                                AppSpacing.bottomNavigationPadding(
                                  context,
                                ).bottom,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Segment: Branding & Identity
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: AppAnimateList.stagger([
                                  const SizedBox(height: 48),

                                  // Logo
                                  Assets.icons.nearVendorText.svg(
                                    height: 32,
                                    colorFilter: ColorFilter.mode(
                                      theme.colorScheme.onSurface,
                                      BlendMode.srcIn,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Welcome Text
                                  Text(
                                    'What ever is near you,\nNearvendor is the nearest',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 28,
                                          height: 1.1,
                                          letterSpacing: -1,
                                        ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'Discover millions of specialized items right in your local neighborhood.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ]),
                              ),

                              // Bottom Segment: Interaction
                              Column(
                                children: AppAnimateList.stagger([
                                  const SizedBox(height: 48),

                                  // Form Section
                                  Form(
                                    key: cubit.formKey,
                                    child: Column(
                                      children: AppAnimateList.stagger([
                                        AuthTextFieldWidget(
                                          label: 'email',
                                          controller: cubit.emailController,
                                          prefixIcon: Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: TextFieldValidators
                                              .emailFieldValidation,
                                        ),

                                        const SizedBox(height: 16),

                                        AuthTextFieldWidget(
                                          label: 'password',
                                          isPassword: true,
                                          controller: cubit.passwordController,
                                          prefixIcon: Icons.lock_outline,
                                          validator: TextFieldValidators
                                              .passwordFieldValidator,
                                        ),
                                      ]),
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  // CTA Button
                                  AppElevatedButton(
                                    onPressed: cubit.handleSignin,
                                    text: 'CONTINUE',
                                  ),

                                  const SizedBox(height: 24),

                                  // Footer Links
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.5),
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
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                        child: Text(
                                          'SIGN UP',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Dynamic spacer for keyboard
                                  SizedBox(
                                    height:
                                        MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom +
                                        24,
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
