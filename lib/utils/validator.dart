class CustomValidator {
  String? validateName(String? value) {
    String pattern = r'(^[a-zA-Z ]*$)';

    if (value == null) {
      return null;
    }

    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null) {
      return null;
    }

    String pattern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "Mobile is Required";
    } else if (value.length != 10) {
      return "Mobile number must 10 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Mobile Number must be digits";
    }
    return null;
  }

  String? validatePasswordLength(String? value) {
    if (value == null) {
      return null;
    }

    const requiredPasswordLength = 8;

    if (value.isEmpty) {
      return "Password can't be empty";
    } else if (value.length < requiredPasswordLength) {
      return "Password must be longer than $requiredPasswordLength characters";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null) {
      return null;
    }

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }
}
