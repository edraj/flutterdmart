class ConfirmOTPRequest {
  final String otp;
  final String? msisdn;
  final String? email;

  ConfirmOTPRequest({
    required this.otp,
    this.msisdn,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'msisdn': msisdn,
      'email': email,
    };
  }
}