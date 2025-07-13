class PasswordResetRequest {
  final String? msisdn;
  final String? shortname;
  final String? email;

  PasswordResetRequest({
    this.msisdn,
    this.shortname,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'msisdn': msisdn,
      'shortname': shortname,
      'email': email,
    };
  }
}