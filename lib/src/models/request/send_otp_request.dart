class SendOTPRequest {
  final String? msisdn;
  final String? email;

  SendOTPRequest({
    this.msisdn,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'msisdn': msisdn,
      'email': email,
    };
  }
}