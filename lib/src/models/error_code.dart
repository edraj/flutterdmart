/// dmart's internal error codes, as sent in `error.code` of a failed
/// response ([Error.code]).
///
/// The numbers are dmart's (`InternalErrorCode`) and never change. The HTTP
/// status of the response is separate: [conflict] arrives with HTTP 409 and
/// [passwordHashingBusy] with HTTP 503, but [otpNeeded] arrives with HTTP 401.
///
/// pydmart and tsdmart carry the same 19 codes under the same name
/// (`DmartErrorCode`).
class DmartErrorCode {
  DmartErrorCode._();

  // Sign-in and accounts

  /// Wrong shortname, email, msisdn or password.
  static const int invalidUsernameAndPass = 10;

  /// A password sign-in named an email or phone the account has not proven
  /// (dmart >= 1.7.10). Every admin-created user starts this way. Offer a
  /// code sign-in ([OtpPurpose.login]) or a reset ([OtpPurpose.reset]) to the
  /// address instead; a sign-in by shortname is not affected.
  static const int userIsntVerified = 11;

  /// The account is locked. A code sign-in on a `locked_to_device` account
  /// from another device, or without `device_id`, also answers this.
  static const int userAccountLocked = 110;

  /// The password was right but a code is needed too. dmart sends a code to
  /// the account; send the same login again with `otp` (and the same
  /// `device_id`). Admins always sign in this way, and since dmart 1.7.2 so
  /// does a mobile account's first sign-in from a device.
  static const int otpNeeded = 115;

  /// The password change or reset was refused, e.g. `old_password` missing on
  /// `POST /user/profile`.
  static const int passwordResetError = 102;

  /// The token or session is not valid. `/user/create` also answers this for
  /// a refused registration (disabled, bad code, rule failed).
  static const int session = 50;

  /// The caller may not do this. A refused write answers this whether or not
  /// the record exists.
  static const int notAllowed = 401;

  // Codes

  /// The code is wrong.
  static const int otpInvalid = 307;

  /// The code was right but has expired; request a new one (dmart >= 1.7.0).
  static const int otpExpired = 308;

  /// A new code was asked for too soon.
  static const int otpResendBlocked = 103;

  // Data

  /// The request is malformed, e.g. a mobile sign-in without `device_id`.
  static const int invalidData = 402;

  /// A required field is missing.
  static const int missingData = 202;

  /// The shortname is taken.
  static const int shortnameAlreadyExist = 400;

  /// An email or msisdn is already used by another account.
  static const int dataShouldBeUnique = 415;

  /// The record changed between authorization and write; read it again and
  /// retry (HTTP 409, dmart >= 1.7.4).
  static const int conflict = 409;

  /// A ticket's state can only change through `progressTicket`.
  static const int invalidTicketStatus = 300;

  /// The server has no such route (HTTP 422).
  static const int invalidRoute = 230;

  // Server

  /// The server is too busy to hash a password right now; retry later
  /// (HTTP 503, error type `server`).
  static const int passwordHashingBusy = 503;

  /// The request ran past the server's timeout and was stopped (HTTP 504).
  static const int requestTimeout = 504;
}
