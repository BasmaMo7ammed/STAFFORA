class AppValidators {
  AppValidators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final regex = RegExp(
      r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
    );

    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    final digits = value.replaceAll(
      RegExp(r'[\s+\-()]'),
      '',
    );

    if (!RegExp(r'^\d{8,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  static String? salary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Salary is required.';
    }

    final amount = double.tryParse(value.trim());

    if (amount == null ||
        !amount.isFinite ||
        amount < 0) {
      return 'Enter a valid salary.';
    }

    return null;
  }
}
