import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/login_cubit/login_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/views/sign_up_screen.dart';
import 'package:nearvendorapp/views/screens/auth/widgets/auth_text_field_widget.dart';
import 'package:nearvendorapp/views/screens/home/view/home_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
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
            AppNavigator.push(context, const MainScreen());
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          return LoadingScreenView(
            isLoading: state is LoginLoading,
            child: AppScaffold(
              body: Stack(
                children: [
                  Image.asset(Assets.images.itemsArt.path, fit: BoxFit.cover),
                  SafeArea(
                    child: Padding(
                      padding: AppSpacing.bottomNavigationPadding(context),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.icons.nearVendorText.svg(),
                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),
                          Text(
                            'What ever is near you,\nNearvendor is the nearest',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),
                          Spacer(),
                          AuthTextFieldWidget(
                            label: 'email',
                            controller: TextEditingController(),
                          ),
                          SizedBox(
                            height: AppSpacing.smallVerticalSpacing(context),
                          ),
                          AuthTextFieldWidget(
                            label: 'password',
                            controller: TextEditingController(),
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
                                style: Theme.of(context).textTheme.bodySmall,
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
