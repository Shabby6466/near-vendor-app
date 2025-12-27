import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/cubit/general_pin_cubit.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';
import 'package:pinput/pinput.dart';

class GeneralPinScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String email;
  final String buttonText;
  final Widget? icon;
  final int pinLength;
  final Function(String code, String email, GeneralPinCubit cubit)
  onPinSubmitted;
  final Function(String code)? onPinChanged;
  final Function(BuildContext context, String email, String code)?
  onSuccessNavigation;
  final bool showBackgroundImage;

  const GeneralPinScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.email,
    required this.buttonText,
    required this.onPinSubmitted,
    this.onPinChanged,
    this.icon,
    this.pinLength = 6,
    this.onSuccessNavigation,
    this.showBackgroundImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: ColorName.primary),
      ),
    );

    return BlocProvider(
      create: (context) => GeneralPinCubit(),
      child: BlocConsumer<GeneralPinCubit, GeneralPinState>(
        listener: (context, state) {
          if (state is GeneralPinSuccess) {
            if (onSuccessNavigation != null) {
              final widget = onSuccessNavigation!(
                context,
                email,
                context.read<GeneralPinCubit>().codeController.text,
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => widget as Widget),
              );
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<GeneralPinCubit>();
          final currentCode = state is GeneralPinCodeChanged
              ? state.code
              : cubit.codeController.text;
          final isButtonEnabled =
              state is! GeneralPinLoading && currentCode.length == pinLength;
          return LoadingScreenView(
            isLoading: state is GeneralPinLoading,
            child: AppScaffold(
              appBar: AppBar(),
              body: Padding(
                padding: AppSpacing.screenPadding(context),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: AppSpacing.mediumVerticalSpacing(context),
                      ),
                      icon ?? Assets.icons.nearVendorText.svg(),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(
                        height: AppSpacing.smallVerticalSpacing(context),
                      ),
                      RichText(
                        text: TextSpan(
                          text: subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                          children: [
                            TextSpan(
                              text: email,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: ColorName.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),
                      Center(
                        child: Pinput(
                          controller: cubit.codeController,
                          length: pinLength,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: focusedPinTheme,
                          onChanged: (code) {
                            cubit.onCodeChanged(code);
                            onPinChanged?.call(code);
                          },
                          cursor: Container(
                            height: 20,
                            width: 1,
                            color: ColorName.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: Padding(
                  padding: AppSpacing.bottomNavigationPadding(context),
                  child: AppElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            AppNavigator.push(context, const MainScreen());
                          }
                        : null,
                    text: buttonText,
                    isEnabled: isButtonEnabled,
                  ),
                  // ElevatedButton(
                  //   onPressed: isButtonEnabled
                  //       ? () {
                  //           AppNavigator.push(context, const HomeScreen());
                  //         }
                  //       : null,
                  //   child: Text(buttonText),
                  // ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
