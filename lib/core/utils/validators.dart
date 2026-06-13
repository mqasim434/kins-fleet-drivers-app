/// Dutch form validation messages.
abstract final class Validators {
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Voer uw e-mailadres in.';
    }
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Voer een geldig e-mailadres in.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Voer uw wachtwoord in.';
    }
    if (value.length < 6) {
      return 'Wachtwoord moet minimaal 6 tekens bevatten.';
    }
    return null;
  }

  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is verplicht.';
    }
    return null;
  }
}
