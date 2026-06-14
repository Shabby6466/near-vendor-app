import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/edit_profile_screen/cubit/edit_profile_cubit.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/edit_profile_screen/cubit/edit_profile_state.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/circular_cached_network_image.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state.status == EditProfileStatus.success) {
            AppAlerts.showSuccess(context, 'Profile updated successfully!');
            AppNavigator.pop(context);
          } else if (state.status == EditProfileStatus.failure &&
              state.errorMessage != null) {
            AppAlerts.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          final cubit = context.read<EditProfileCubit>();
          final isSubmitting = state.status == EditProfileStatus.submitting;

          return LoadingScreenView(
            isLoading: isSubmitting,
            child: Scaffold(
              appBar: AppBar(title: const Text('Edit Profile')),
              body: SingleChildScrollView(
                padding: AppSpacing.screenPadding(context),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: state.pickedImage != null
                                    ? Image.file(
                                        state.pickedImage!,
                                        width: 130,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      )
                                    : CircularCachedNetworkImage(
                                        imageUrl: state.photoUrl,
                                        size: 130,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: isSubmitting
                                    ? null
                                    : () => cubit.pickImage(),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Input section title/label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          'Full Name',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge?.color?.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ),

                      // Styled TextFormField wrapper matching existing theme
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: AppTextField(
                          controller: cubit.nameController,
                          hint: 'Enter your full name',
                          validator: (value) =>
                              TextFieldValidators.emptyFieldValidator(
                                value,
                                'Please enter your full name',
                              ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      AppElevatedButton(
                        onPressed: () =>
                            context.read<EditProfileCubit>().updateProfile(),
                        text: 'Save Changes',
                        isLoading: isSubmitting,
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
