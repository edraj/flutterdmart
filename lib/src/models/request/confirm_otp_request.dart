class ConfirmOTPRequest {
  ConfirmOTPRequest({required this.otp, this.msisdn, this.email});
  final String otp;
  final String? msisdn;
  final String? email;

  Map<String, dynamic> toJson() {
    return {'otp': otp, 'msisdn': msisdn, 'email': email};
  }
}
