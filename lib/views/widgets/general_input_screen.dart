import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
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
    this.title = '',
    this.subtitle = '',
    this.email = '',
    this.buttonText = '',
    required this.onPinSubmitted,
    this.onPinChanged,
    this.icon,
    this.pinLength = 6,
    this.onSuccessNavigation,
    this.showBackgroundImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: theme.textTheme.titleLarge?.color,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: (0.1))),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: theme.primaryColor, width: 2),
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
          } else if (state is GeneralPinFailure) {
            AppAlerts.showErrorSnackBar(context, state.message);
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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: theme.iconTheme,
              ),
              body: Padding(
                padding: AppSpacing.screenPadding(context),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: AppSpacing.mediumVerticalSpacing(context),
                      ),
                      icon ??
                          Assets.icons.nearVendorText.svg(
                            colorFilter: ColorFilter.mode(
                              theme.primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),
                      Text(
                        title,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: AppSpacing.smallVerticalSpacing(context),
                      ),
                      RichText(
                        text: TextSpan(
                          text: subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: (0.7)),
                            fontFamily: 'Poppins',
                          ),
                          children: [
                            TextSpan(
                              text: ' $email',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
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
                            width: 2,
                            color: theme.primaryColor,
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
                        ? () => onPinSubmitted(
                            cubit.codeController.text,
                            email,
                            cubit,
                          )
                        : null,
                    text: buttonText,
                    isEnabled: isButtonEnabled,
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
