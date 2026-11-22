// Second factors (dmart >= 1.8.1): the second step on login, reading the step
// a sign-in asks for, a key through the device's passkey API (and the plugin adapter), key-only
// sign-in, and an authenticator app's setup.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dmart/dmart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passkeys/authenticator.dart' as plugin;
import 'package:passkeys/types.dart' as plugin;

/// Records each request; answers each path from its queue in turn.
class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.queues);

  final Map<String, List<(int, Object)>> queues;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final queue = queues[options.path];
    final (status, body) = (queue == null || queue.isEmpty) ? (200, {'status': 'success'}) : queue.removeAt(0);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

/// A phone's passkey API: records the options it got and answers with a fixed credential.
class _FakeKey implements PasskeyDevice {
  final asked = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> getCredential(Map<String, dynamic> options) async {
    asked.add(options);
    return {'id': 'k1', 'rawId': 'k1', 'type': 'public-key', 'response': {'signature': 'c2ln'}};
  }

  @override
  Future<Map<String, dynamic>> createCredential(Map<String, dynamic> options) async {
    asked.add(options);
    return {'id': 'k2', 'rawId': 'k2', 'type': 'public-key', 'response': {'attestationObject': 'YXR0'}};
  }
}

/// The passkeys plugin's authenticator, answering as a phone would.
class _FakePlugin implements plugin.PasskeyAuthenticator {
  plugin.AuthenticateRequestType? asked;
  plugin.RegisterRequestType? made;

  @override
  Future<plugin.AuthenticateResponseType> authenticate(plugin.AuthenticateRequestType request) async {
    asked = request;
    return const plugin.AuthenticateResponseType(
      id: 'k1', rawId: 'k1', clientDataJSON: 'Y2Q', authenticatorData: 'YWQ', signature: 'c2ln', userHandle: '');
  }

  @override
  Future<plugin.RegisterResponseType> register(plugin.RegisterRequestType request) async {
    made = request;
    return const plugin.RegisterResponseType(
      id: 'k2', rawId: 'k2', clientDataJSON: 'Y2Q', attestationObject: 'YXR0', transports: ['usb', 'nfc']);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _signedIn = {
  'status': 'success',
  'records': [
    {'resource_type': 'user', 'shortname': 'ali', 'subpath': '/users', 'attributes': {'access_token': 'tok', 'type': 'web'}},
  ],
};

(int, Object) _step(List<String> factors, {bool key = false}) => (401, {
  'status': 'failed',
  'error': {
    'type': 'auth',
    'code': DmartErrorCode.otpNeeded,
    'message': 'second step',
    'info': [
      {
        'factors': factors,
        if (key) 'webauthn': {'challenge_id': 'c1', 'options': {'challenge': 'AQID', 'rpId': 'dmart.test'}},
      },
    ],
  },
});

void main() {
  late _QueueAdapter adapter;

  void serve(Map<String, List<(int, Object)>> queues) {
    adapter = _QueueAdapter(queues);
    Dmart.deviceId = null;
    Dmart.initDmart(dio: Dio(BaseOptions(baseUrl: 'http://dmart.test'))..httpClientAdapter = adapter);
    Dmart.token = null;
  }

  Map<String, dynamic> body(int i) => Map<String, dynamic>.from(adapter.requests[i].data as Map);

  test('a password step that asks for an app code is read off the error', () async {
    serve({'/user/login': [_step(['totp', 'recovery'])]});
    final (_, err) = await Dmart.login(LoginRequest(shortname: 'ali', password: 'pw'));
    expect(err!.code, DmartErrorCode.otpNeeded);
    expect(err.secondFactor!.factors, ['totp', 'recovery']);
    expect(err.secondFactor!.wantsAppCode, isTrue);
    expect(err.secondFactor!.wantsKey, isFalse);
  });

  test('the second step sends the app code with the password', () async {
    serve({'/user/login': [(200, _signedIn)]});
    await Dmart.login(LoginRequest.withSecondFactor(shortname: 'ali', password: 'pw', totp: '123456'));
    expect(body(0), {'shortname': 'ali', 'password': 'pw', 'totp': '123456'});
    expect(Dmart.token, 'tok');
  });

  test('loginWithSecurityKey hands the options to the device and sends its answer back', () async {
    serve({'/user/login': [_step(['passkey', 'recovery'], key: true), (200, _signedIn)]});
    final key = _FakeKey();
    final (done, err) = await Dmart.loginWithSecurityKey(LoginRequest(shortname: 'ali', password: 'pw'), device: key);
    expect(err, isNull);
    expect(done!.token, 'tok');
    expect(key.asked.single, {'challenge': 'AQID', 'rpId': 'dmart.test'});
    expect(body(1)['password'], 'pw');
    expect(body(1)['webauthn'], {
      'challenge_id': 'c1',
      'credential': {'id': 'k1', 'rawId': 'k1', 'type': 'public-key', 'response': {'signature': 'c2ln'}},
    });
  });

  test('loginWithKeyAlone takes the challenge for the name and sends no password', () async {
    serve({
      '/user/passkeys/login-options': [
        (200, {'status': 'success', 'attributes': {'challenge_id': 'k9', 'options': {'challenge': 'BA'}}}),
      ],
      '/user/login': [(200, _signedIn)],
    });
    final (done, err) = await Dmart.loginWithKeyAlone(shortname: 'ali', device: _FakeKey());
    expect(err, isNull);
    expect(done!.token, 'tok');
    expect(body(0), {'shortname': 'ali'});
    expect(body(1).containsKey('password'), isFalse);
    expect((body(1)['webauthn'] as Map)['challenge_id'], 'k9');
  });

  test('an authenticator app is set up and the account reads it back', () async {
    serve({
      '/user/totp/begin': [
        (200, {'status': 'success', 'attributes': {'setup_id': 's1', 'secret': 'GEZD', 'uri': 'otpauth://totp/x'}}),
      ],
      '/user/totp/confirm': [
        (200, {'status': 'success', 'attributes': {'recovery_codes': ['AAAAA-BBBBB']}}),
      ],
      '/user/passkeys': [
        (200, {'status': 'success', 'attributes': {'passkeys': [], 'totp': true, 'totp_may_add': true, 'recovery_codes_left': 10}}),
      ],
    });
    Dmart.token = 'tok';
    final (setup, _) = await Dmart.totpBegin(const SecondFactorProof(password: 'pw'));
    expect(setup!.uri, 'otpauth://totp/x');
    expect(body(0), {'password': 'pw'});
    expect(adapter.requests[0].headers['Authorization'], 'Bearer tok');
    final (codes, _) = await Dmart.totpConfirm('s1', '123456');
    expect(codes, ['AAAAA-BBBBB']);
    final (state, _) = await Dmart.getSecondFactors();
    expect(state!.hasApp, isTrue);
    expect(state.recoveryCodesLeft, 10);
  });

  test('adding a key goes through the device and returns the recovery codes', () async {
    serve({
      '/user/passkeys/register-options': [
        (200, {'status': 'success', 'attributes': {'challenge_id': 'r1', 'options': {'challenge': 'Cg', 'user': {'id': 'dQ'}}}}),
      ],
      '/user/passkeys/register': [
        (200, {'status': 'success', 'attributes': {'id': 'k2', 'name': 'Phone', 'recovery_codes': ['CCCCC-DDDDD']}}),
      ],
    });
    Dmart.token = 'tok';
    final key = _FakeKey();
    final (codes, err) = await Dmart.addSecurityKey(const SecondFactorProof(password: 'pw'), name: 'Phone', device: key);
    expect(err, isNull);
    expect(codes, ['CCCCC-DDDDD']);
    expect(key.asked.single['challenge'], 'Cg');
    expect(body(1)['name'], 'Phone');
    expect((body(1)['webauthn'] as Map)['challenge_id'], 'r1');
  });

  test('PlatformPasskeys hands dmart\'s options to the plugin and its credential back as dmart takes it', () async {
    final phone = _FakePlugin();
    final device = PlatformPasskeys(phone);

    final signed = await device.getCredential({
      'challenge': 'AQID',
      'rpId': 'dmart.test',
      'timeout': 60000,
      'userVerification': 'required',
      'allowCredentials': [
        {'type': 'public-key', 'id': 'BwcH', 'transports': ['usb', 'nfc']},
      ],
    });
    expect(phone.asked!.relyingPartyId, 'dmart.test');
    expect(phone.asked!.challenge, 'AQID');
    expect(phone.asked!.allowCredentials!.single.id, 'BwcH');
    expect(phone.asked!.preferImmediatelyAvailableCredentials, isFalse, reason: 'a USB or NFC key is offered too');
    expect(signed['id'], 'k1');
    expect(signed['type'], 'public-key');
    expect(signed['response'], {'clientDataJSON': 'Y2Q', 'authenticatorData': 'YWQ', 'signature': 'c2ln'});

    final made = await device.createCredential({
      'challenge': 'Cg',
      'rp': {'id': 'dmart.test', 'name': 'dmart'},
      'user': {'id': 'dQ', 'name': 'ali', 'displayName': 'Ali'},
      'pubKeyCredParams': [{'type': 'public-key', 'alg': -7}],
      'excludeCredentials': [],
      'authenticatorSelection': {'residentKey': 'preferred', 'userVerification': 'required'},
      'attestation': 'none',
      'timeout': 60000,
    });
    expect(phone.made!.relyingParty.id, 'dmart.test');
    expect(phone.made!.user.id, 'dQ');
    expect(made['response'], {'clientDataJSON': 'Y2Q', 'attestationObject': 'YXR0', 'transports': ['usb', 'nfc']});
  });

  test('the two new codes are dmart\'s', () {
    expect(DmartErrorCode.secondFactorRequired, 116);
    expect(DmartErrorCode.secondFactorInvalid, 117);
  });
}
