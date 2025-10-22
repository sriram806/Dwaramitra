class AuthCredentials {
  final String email;
  final String password;

  const AuthCredentials({
    required this.email,
    required this.password,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthCredentials &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(email, password);

  @override
  String toString() => 'AuthCredentials(email: $email)';
}

class SignUpCredentials {
  final String name;
  final String email;
  final String password;
  final String? gender;

  const SignUpCredentials({
    required this.name,
    required this.email,
    required this.password,
    this.gender,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignUpCredentials &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.gender == gender;
  }

  @override
  int get hashCode => Object.hash(name, email, password, gender);

  @override
  String toString() => 'SignUpCredentials(name: $name, email: $email)';
}

class OtpVerification {
  final String otp;

  const OtpVerification({
    required this.otp,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtpVerification && other.otp == otp;
  }

  @override
  int get hashCode => otp.hashCode;

  @override
  String toString() => 'OtpVerification(otp: $otp)';
}

class PasswordReset {
  final String email;
  final String otp;
  final String newPassword;

  const PasswordReset({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordReset &&
        other.email == email &&
        other.otp == otp &&
        other.newPassword == newPassword;
  }

  @override
  int get hashCode => Object.hash(email, otp, newPassword);

  @override
  String toString() => 'PasswordReset(email: $email)';
}