class PasswordResetRequest {
  PasswordResetRequest({this.msisdn, this.shortname, this.email});
  final String? msisdn;
  final String? shortname;
  final String? email;

  Map<String, dynamic> toJson() {
    return {'msisdn': msisdn, 'shortname': shortname, 'email': email};
  }
}
