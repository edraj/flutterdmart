/// What an OTP issued by `POST /user/otp-request` can be redeemed for.
///
/// A code only works for the purpose it was issued with: a `login` code
/// cannot complete a signup, a `reset` code cannot log in, and so on.
class OtpPurpose {
  OtpPurpose._();

  /// Redeemed by `POST /user/login` with `otp`.
  static const String login = 'login';

  /// Redeemed by `POST /user/password-reset-confirm`.
  static const String reset = 'reset';

  /// Redeemed by `POST /user/create` (`email_otp` / `msisdn_otp`).
  static const String register = 'register';

  /// Redeemed by `POST /user/verify-contact`. Requires a logged-in user.
  static const String verifyContact = 'verify-contact';
}
