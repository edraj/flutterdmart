## 2.14.0
**Compatibility:** Requires csdmart ≥ 1.6.12 (getClientConfig needs it; getPermissions falls back to the profile and the rest works on older servers). Top-level `shortname` on sign-up and the username rule in client config need ≥ 1.7.9. Aligned with csdmart 1.7.10.

### Added
- `getClientConfig()` and `ClientConfig` read `GET /public/client-config`: code length and resend wait, upload and query limits, and the password and username rules with their hints. No sign-in is needed.
- `DmartErrorCode`: dmart's error codes as constants, the same 19 pydmart and tsdmart carry under the same name, among them `otpNeeded` (115), `otpInvalid` (307), `otpExpired` (308), `userIsntVerified` (11), `userAccountLocked` (110), `conflict` (409), `invalidTicketStatus` (300), `passwordResetError` (102), `invalidData` (402), `notAllowed` (401), `passwordHashingBusy` (503) and `requestTimeout` (504).
- `LoginRequest.withPasswordAndOTP` for the second step of a sign-in that answered `OTP_NEEDED` (115). Admins always sign in this way, and since dmart 1.7.2 so does a mobile account's first sign-in from a device.
- `Dmart.deviceId` (also `initDmart(deviceId:)`) is sent as `X-DeviceId` on `login` when the request has no `deviceID` of its own. dmart ≥ 1.7.2 refuses a mobile sign-in without a device id.
- `VerifyContactRequest.password` and `currentCode` (`current_code`). Changing an address needs one of them: the password on an account that has one, otherwise a code sent to the existing address.
- `UserType.admin` and `ContentType.binary`. Until now an admin's sign-in failed to parse.
- `ProfileResponseRecordAttributes.mailbox`, `mailAliases` and `services`.
- Query `attributes.totalIsLowerBound` (`total_is_lower_bound`), which is set when `total` is the server's cap rather than the exact count.

### Changed
- `createUser` sends only fields dmart's `/user/create` reads: the top-level `shortname` plus `displayname`, `email`, `msisdn`, `password`, `language`, `email_otp` and `msisdn_otp`. (dmart also accepts `description`, `tags` and a `payload` on sign-up, which `CreateUserAttributes` does not carry yet.) The `subpath` and `resource_type` wrapper fields are gone. On the attributes, `invitation`, `profilePicUrl`, `roles`, `groups`, `firebaseToken`, `deviceID`, `isEmailVerified`, `isMsisdnVerified` and `forcePasswordChange` are deprecated and no longer sent, and `is_active` is no longer sent either. dmart never applied any of them on self-registration. `invitation` is now optional.
- Documented, on `login`, `createUser`, `updateProfile` and `verifyContact`: the `OTP_NEEDED` two-step; `USER_ISNT_VERIFIED` (11) for a password sign-in naming an unproven address (dmart ≥ 1.7.10); the registration codes, which dmart ≥ 1.7.10 always requires when registration is open; and `old_password` for a password change.
- `QueryRequest.validateSchema` is deprecated, because dmart ≥ 1.5.0 ignores it. A null `limit` gets the server's default.

### Fixed
- `attach` posted to `/attach/{space}`, a route dmart doesn't have. It now posts to `/public/attach/{space}`, and it no longer requires a token, since the route is anonymous.

### Removed
- `userReset`. dmart dropped `/user/reset`, so the call always failed against csdmart.

## 2.13.0
- Add `getPermissions`, which reads the caller's permission map from `/user/permissions`. dmart deprecates the copy in `/user/profile`, the heaviest part of that response, in favour of this route. A server without the route answers `INVALID_ROUTE` (230, HTTP 422); that answer, or a bare 404, is answered from the profile's map.
- `getProfile` no longer fails on a profile without `permissions`; `ProfileResponseRecordAttributes.permissions` is then empty. Until now a server that left the map out made every `getProfile` call throw.
- Add `Permission.mapFromJson`.

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
