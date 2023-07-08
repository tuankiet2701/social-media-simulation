class Validations {
  static String? validateName(String? value) {
    if (value!.isEmpty) return 'Username is Required.';
    final RegExp nameExp = new RegExp(r'^[a-zA-Z0-9._]{1,20}$');
    if (!nameExp.hasMatch(value)) return 'Invalid Username';
  }

  static String? validateEmail(String? value, [bool isRequried = true]) {
    if (value!.isEmpty && isRequried) return 'Email is required.';
    final RegExp nameExp = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!nameExp.hasMatch(value) && isRequried) return 'Invalid email address';
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty || value.length < 6) return 'Password is too short';
  }
}
