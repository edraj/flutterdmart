## 2.12.0
- Use the OTP routes of dmart >= 1.4.0, which removed `/user/otp-request-login`, `/user/password-reset-request` and `/user/otp-confirm`:
  - `otpRequestLogin` and `passwordResetRequest` now call `/user/otp-request` with purpose `login` / `reset`.
  - `confirmOTP` now calls `/user/verify-contact`.
  - All three are deprecated in favour of `otpRequest` and `verifyContact`.
- Add `passwordResetConfirm` (`/user/password-reset-confirm`) and `PasswordResetConfirmRequest`.
- Add `OtpPurpose` constants.
- Export `VerifyContactRequest`, which `verifyContact` takes but the package did not export.
- `otpRequest` sends the token for `verify-contact`; `verifyContact` no longer sends null fields.

## 2.8.0
- Relicense under LGPL-3.0-or-later
- Upgrade dependencies to latest (dio 5.11, lints 6, test 1.31) to pick up CVE fixes
- Raise minimum Dart SDK to ^3.8.0 (required by lints 6)

## 1.1.0
- add update profile

## 1.0.10+2
- formated code
- upgrading deps

## 1.0.9
- Implementing dmart features up to dmart@1.3.5+
- Extending ResourceType: +reaction
- Extending QueryType: +update, +delete
- Extending dmart init to allow dio configuration.
- remove deprecated feature `branch`.

## 1.0.7

- Implementing dmart features up to dmart@1.1.12

## 1.0.0

- Initial version.
