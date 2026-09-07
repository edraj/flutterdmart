class SendOTPRequest {
  final String? shortname;
  final String? msisdn;
  final String? email;
  final String purpose;

  SendOTPRequest({
    this.shortname,
    this.msisdn,
    this.email,
   required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'shortname': shortname,
      'msisdn': msisdn,
      'email': email,
      'purpose': purpose
    };
  }
}
