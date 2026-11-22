// Second factors (dmart >= 1.8.1): a security key or passkey, an
// authenticator app (TOTP), recovery codes, and key-only sign-in.

/// The device's passkey API: [PlatformPasskeys] by default, which is Android's
/// Credential Manager, iOS's and macOS's AuthenticationServices, Windows Hello,
/// or the browser's `navigator.credentials` on the web. Another implementation
/// stands in for it in tests, or wraps another plugin.
///
/// dmart's options are the WebAuthn JSON those APIs take (base64url fields),
/// and the credential they return, as JSON, is what dmart takes back. A phone
/// offers the keys only to an app the server's domain names (dmart's
/// `WEBAUTHN_ANDROID_APPS` / `WEBAUTHN_IOS_APPS`).
abstract interface class PasskeyDevice {
  /// Asks a key to sign: [options] are WebAuthn request options. Returns the
  /// PublicKeyCredential as JSON.
  Future<Map<String, dynamic>> getCredential(Map<String, dynamic> options);

  /// Asks for a new key: [options] are WebAuthn creation options. Returns the
  /// PublicKeyCredential as JSON.
  Future<Map<String, dynamic>> createCredential(Map<String, dynamic> options);
}

/// A WebAuthn challenge from dmart: its id, and the options for the key.
class KeyChallenge {
  final String challengeId;
  final Map<String, dynamic> options;

  const KeyChallenge({required this.challengeId, required this.options});

  factory KeyChallenge.fromJson(Map<String, dynamic> json) => KeyChallenge(
    challengeId: json['challenge_id'] as String,
    options: Map<String, dynamic>.from(json['options'] as Map),
  );
}

/// A key's answer, as dmart takes it: the challenge it answers and the
/// PublicKeyCredential as JSON.
class KeyAnswer {
  final String challengeId;
  final Map<String, dynamic> credential;

  const KeyAnswer({required this.challengeId, required this.credential});

  Map<String, dynamic> toJson() => {'challenge_id': challengeId, 'credential': credential};
}

/// What a password sign-in asks next: `error.info[0]` of an
/// [DmartErrorCode.otpNeeded] (115) answer for an account with a second
/// factor, or of a [DmartErrorCode.secondFactorRequired] (116) answer
/// carrying an admin's key setup. Read it with [Error.secondFactor].
class SecondFactorStep {
  /// What the account may use: `passkey`, `totp`, `recovery`, or `passkey_setup`.
  final List<String> factors;

  /// The challenge for the account's key, with `passkey` or `passkey_setup`.
  final KeyChallenge? webauthn;

  const SecondFactorStep({required this.factors, this.webauthn});

  bool get wantsKey => factors.contains('passkey') && webauthn != null;
  bool get wantsAppCode => factors.contains('totp');
}

/// The proof a change to an account's second factors carries: the password,
/// and once the account has a key, that key's answer to a proof challenge
/// ([Dmart.securityKeyProof]); with an app and no key, the app's code. An
/// account that signs in with its key alone proves itself with the key.
class SecondFactorProof {
  final String? password;
  final KeyAnswer? webauthn;
  final String? totp;

  const SecondFactorProof({this.password, this.webauthn, this.totp});

  Map<String, dynamic> toJson() => {
    if (password != null) 'password': password,
    if (webauthn != null) 'webauthn': webauthn!.toJson(),
    if (totp != null) 'totp': totp,
  };
}

/// `GET /user/passkeys`: the signed-in account's second factors.
class SecondFactors {
  final List<Map<String, dynamic>> passkeys;
  final int recoveryCodesLeft;
  final bool mayAddKey;
  final bool keyOnly;
  final bool hasApp;
  final String? appAddedAt;
  final bool mayAddApp;

  const SecondFactors({
    required this.passkeys,
    required this.recoveryCodesLeft,
    required this.mayAddKey,
    required this.keyOnly,
    required this.hasApp,
    this.appAddedAt,
    required this.mayAddApp,
  });

  factory SecondFactors.fromJson(Map<String, dynamic> json) => SecondFactors(
    passkeys: [for (final k in (json['passkeys'] as List? ?? [])) Map<String, dynamic>.from(k as Map)],
    recoveryCodesLeft: json['recovery_codes_left'] as int? ?? 0,
    mayAddKey: json['may_add'] == true,
    keyOnly: json['key_only'] == true,
    hasApp: json['totp'] == true,
    appAddedAt: json['totp_added_at'] as String?,
    mayAddApp: json['totp_may_add'] == true,
  );
}

/// An authenticator app being added: [uri] (`otpauth://`) for the QR code,
/// or [secret] to type in. Confirm it with a code from the app.
class TotpSetup {
  final String setupId;
  final String secret;
  final String uri;

  const TotpSetup({required this.setupId, required this.secret, required this.uri});

  factory TotpSetup.fromJson(Map<String, dynamic> json) => TotpSetup(
    setupId: json['setup_id'] as String,
    secret: json['secret'] as String,
    uri: json['uri'] as String,
  );
}
