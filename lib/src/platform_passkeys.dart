// The device's own passkey API, through the `passkeys` plugin: Android's
// Credential Manager, iOS's and macOS's AuthenticationServices, Windows Hello,
// and `navigator.credentials` on the web.
import 'package:dmart/src/models/second_factors.dart';
import 'package:passkeys/authenticator.dart' as plugin;
import 'package:passkeys/types.dart' as plugin;

/// [PasskeyDevice] on the device's own passkey API: what
/// [Dmart.loginWithSecurityKey], [Dmart.loginWithKeyAlone],
/// [Dmart.securityKeyProof] and [Dmart.addSecurityKey] use unless given
/// another. The plugin's exceptions (`PasskeyAuthCancelledException` and the
/// rest) come back as those calls' client error.
class PlatformPasskeys implements PasskeyDevice {
  PlatformPasskeys([plugin.PasskeyAuthenticator? authenticator])
      : _authenticator = authenticator ?? plugin.PasskeyAuthenticator();

  final plugin.PasskeyAuthenticator _authenticator;

  @override
  Future<Map<String, dynamic>> getCredential(Map<String, dynamic> options) async {
    // Not only the passkeys this device holds: a security key over USB or NFC,
    // and a phone nearby, are offered too.
    final request = plugin.AuthenticateRequestType.fromJson(options, preferImmediatelyAvailableCredentials: false);
    return (await _authenticator.authenticate(request)).toJson();
  }

  @override
  Future<Map<String, dynamic>> createCredential(Map<String, dynamic> options) async =>
      (await _authenticator.register(plugin.RegisterRequestType.fromJson(options))).toJson();
}
