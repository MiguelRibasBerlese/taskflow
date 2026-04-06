import 'constants.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.required;
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.required;
    }
    if (value.length < AppConfig.passwordMinLength) {
      return 'A senha deve ter no mínimo ${AppConfig.passwordMinLength} caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;
    if (value != original) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static String? required(String? value, {String? label}) {
    if (value == null || value.trim().isEmpty) {
      return label != null ? '$label é obrigatório' : AppStrings.required;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.required;
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Informe um telefone válido: (XX) XXXXX-XXXX';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.required;
    }
    if (value.trim().length < 3) {
      return 'O nome deve ter no mínimo 3 caracteres';
    }
    return null;
  }
}
