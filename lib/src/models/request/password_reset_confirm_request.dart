class PasswordResetConfirmRequest {
  final String? shortname;
  final String? msisdn;
  final String? email;
  final String otp;
  final String password;

  PasswordResetConfirmRequest({
    this.shortname,
    this.msisdn,
    this.email,
    required this.otp,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'shortname': shortname,
      'msisdn': msisdn,
      'email': email,
      'otp': otp,
      'password': password,
    };
  }
}
