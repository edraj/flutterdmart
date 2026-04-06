class SendOTPRequest {
  SendOTPRequest({this.shortname, this.msisdn, this.email});
  final String? shortname;
  final String? msisdn;
  final String? email;

  Map<String, dynamic> toJson() {
    return {'shortname': shortname, 'msisdn': msisdn, 'email': email};
  }
}
