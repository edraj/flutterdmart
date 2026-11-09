class VerifyContactRequest {
  final String? shortname;
  final String? msisdn;
  final String? email;

  /// The verify-contact code sent to [email] or [msisdn].
  final String code;

  /// The account's password. Needed to change the address on an account
  /// that has one (dmart >= 1.6.7); not needed to confirm the address
  /// already on the account.
  final String? password;

  /// On a passwordless account, a verify-contact code sent to its existing
  /// phone, else its existing email. Needed instead of [password] to change
  /// the address (dmart >= 1.6.7).
  final String? currentCode;

  VerifyContactRequest({this.shortname, this.msisdn, this.email, required this.code, this.password, this.currentCode});

  Map<String, dynamic> toJson() {
    return {
      'shortname': shortname,
      'msisdn': msisdn,
      'email': email,
      'code': code,
      'password': password,
      'current_code': currentCode,
    };
  }
}
