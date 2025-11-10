class SendOTPRequest {
  final String? shortname;
  final String? msisdn;
  final String? email;

  SendOTPRequest({
    this.shortname,
    this.msisdn,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'shortname': shortname,
      'msisdn': msisdn,
      'email': email,
    };
  }
}