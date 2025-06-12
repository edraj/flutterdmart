class CheckExistingParams {
  final String? shortname;
  final String? msisdn;
  final String? email;

  CheckExistingParams({
    this.shortname,
    this.msisdn,
    this.email,
  });

  Map<String, String?> toQueryParams() {
    return {
      'shortname': shortname,
      'msisdn': msisdn,
      'email': email,
    };
  }
}