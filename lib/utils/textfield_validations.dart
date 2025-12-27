class TextFieldValidators {
  TextFieldValidators._();

  static String? emailFieldValidation(String? email) {
    if (email!.isEmpty ||
        !RegExp(
          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
        ).hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? passwordFieldValidator(String? password) {
    if (password?.isEmpty ?? true) {
      return 'Please enter your password';
    } else if (password!.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  static String? emptyFieldValidator(String? value, String message) {
    if (value?.isEmpty ?? true && value != null) {
      return message;
    }
    return null;
  }

  static String? confirmPasswordValidator(
    String? value,
    String password,
  ) {
    if (value != null && value.trim().isEmpty) {
      return 'Please confirm your password';
    } else if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
