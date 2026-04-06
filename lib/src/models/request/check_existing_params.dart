class CheckExistingParams {
  CheckExistingParams({this.shortname, this.msisdn, this.email});
  final String? shortname;
  final String? msisdn;
  final String? email;

  Map<String, String?> toQueryParams() {
    return {'shortname': shortname, 'msisdn': msisdn, 'email': email};
  }
}
