class Validators {
  Validators._();

  static bool validateEmail(String value) {
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(value);
  }

  static validPassword(String password) {
    // String pattern = r'^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,20}$';
    String pattern = r'^.{6,20}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }
}