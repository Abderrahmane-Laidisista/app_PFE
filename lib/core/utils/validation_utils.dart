/// Form and clinical input validation utilities.
class ValidationUtils {
  ValidationUtils._();

  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidAge(num? age) {
    if (age == null) return false;
    return age >= 0 && age <= 120;
  }

  static bool isValidDiameter(num? diameter) {
    if (diameter == null) return false;
    return diameter > 0 && diameter <= 200;
  }
}
