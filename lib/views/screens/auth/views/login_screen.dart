import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/login_cubit/login_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/views/sign_up_screen.dart';
import 'package:nearvendorapp/views/screens/auth/widgets/auth_text_field_widget.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.read<SessionCubit>().setAuthenticated(state.user);
            AppNavigator.push(context, const MainScreen());
          } else if (state is LoginFailure) {
            AppAlerts.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          return LoadingScreenView(
            isLoading: state is LoginLoading,
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
                    child: Padding(
                      padding: AppSpacing.bottomNavigationPadding(context),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.icons.nearVendorText.svg(
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),
                          Text(
                            'What ever is near you,\nNearvendor is the nearest',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
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
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),
                          AppElevatedButton(
                            onPressed: () {
                              cubit.handleSignin();
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
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  AppNavigator.push(
                                    context,
                                    const SignUpScreen(),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
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
