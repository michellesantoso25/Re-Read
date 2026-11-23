/// Validation rules for standard buyer/seller marketplace accounts.
class AccountValidation {
  AccountValidation._();

  static final RegExp email = RegExp(
    r"^[A-Za-z0-9.!#$%&\'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );

  static final RegExp fullName = RegExp(
    r"^[A-Za-zÀ-ÖØ-öø-ÿĀ-ž](?:[A-Za-zÀ-ÖØ-öø-ÿĀ-ž' -]{0,78}[A-Za-zÀ-ÖØ-öø-ÿĀ-ž])?$",
  );

  static final RegExp strongPassword = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d).{8,72}$',
  );

  static final RegExp indonesiaPhone = RegExp(r'^(?:\+?62|0)8[1-9]\d{7,10}$');

  static String? validateEmail(String value) {
    final emailValue = value.trim();
    if (emailValue.isEmpty) return 'Email wajib diisi.';
    if (emailValue.length > 254 || !email.hasMatch(emailValue)) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  static String? validateNewPassword(String value) {
    if (!strongPassword.hasMatch(value)) {
      return 'Password harus 8–72 karakter dan berisi huruf serta angka.';
    }
    return null;
  }

  static String? validateFullName(String value) {
    final name = value.trim();
    if (name.length < 2 || name.length > 80 || !fullName.hasMatch(name)) {
      return 'Nama 2–80 karakter; gunakan huruf, spasi, apostrof, atau tanda hubung.';
    }
    return null;
  }

  static String? validatePhone(String value) {
    final normalized = value.replaceAll(RegExp(r'[\s().-]'), '');
    if (!indonesiaPhone.hasMatch(normalized)) {
      return 'Masukkan nomor HP Indonesia yang valid, misalnya 081234567890.';
    }
    return null;
  }
}
