class VerifyContactRequest {
  final String? shortname;
  final String? msisdn;
  final String? email;
  final String code;

  VerifyContactRequest({this.shortname, this.msisdn, this.email, required this.code});

  Map<String, dynamic> toJson() {
    return {'shortname': shortname, 'msisdn': msisdn, 'email': email, 'code': code};
  }
}
