// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dmart/dmart.dart';
import 'package:test/test.dart';

/// Records each request and answers with a dmart success body.
class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'status': 'success'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _RecordingAdapter adapter;

  setUp(() {
    adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://dmart.test'))..httpClientAdapter = adapter;
    Dmart.initDmart(dio: dio);
    Dmart.token = null;
  });

  RequestOptions only() {
    expect(adapter.requests, hasLength(1));
    return adapter.requests.single;
  }

  test('otpRequest sends the purpose to /user/otp-request', () async {
    final (res, err) = await Dmart.otpRequest(SendOTPRequest(email: 'me@x.com', purpose: OtpPurpose.register));
    expect(err, isNull);
    expect(res, isNotNull);
    final r = only();
    expect(r.path, '/user/otp-request');
    expect(r.data, {'email': 'me@x.com', 'purpose': 'register'});
    expect(r.headers.containsKey('Authorization'), isFalse);
  });

  test('otpRequest sends the token for verify-contact', () async {
    Dmart.token = 'tok';
    await Dmart.otpRequest(SendOTPRequest(msisdn: '9647701234567', purpose: OtpPurpose.verifyContact));
    expect(only().headers['Authorization'], 'Bearer tok');
  });

  test('otpRequestLogin goes to /user/otp-request with purpose login', () async {
    await Dmart.otpRequestLogin(SendOTPRequest(msisdn: '9647701234567', purpose: 'whatever'));
    final r = only();
    expect(r.path, '/user/otp-request');
    expect(r.data, {'msisdn': '9647701234567', 'purpose': 'login'});
  });

  test('passwordResetRequest goes to /user/otp-request with purpose reset', () async {
    await Dmart.passwordResetRequest(PasswordResetRequest(shortname: 'alice'));
    final r = only();
    expect(r.path, '/user/otp-request');
    expect(r.data, {'shortname': 'alice', 'purpose': 'reset'});
  });

  test('passwordResetConfirm posts otp and password', () async {
    await Dmart.passwordResetConfirm(
      PasswordResetConfirmRequest(email: 'me@x.com', otp: '123456', password: 'NewPass1!'),
    );
    final r = only();
    expect(r.path, '/user/password-reset-confirm');
    expect(r.data, {'email': 'me@x.com', 'otp': '123456', 'password': 'NewPass1!'});
  });

  test('confirmOTP goes to /user/verify-contact with the otp as code', () async {
    Dmart.token = 'tok';
    await Dmart.confirmOTP(ConfirmOTPRequest(otp: '123456', email: 'me@x.com'));
    final r = only();
    expect(r.path, '/user/verify-contact');
    expect(r.data, {'email': 'me@x.com', 'code': '123456'});
    expect(r.headers['Authorization'], 'Bearer tok');
  });

  test('verifyContact omits null fields', () async {
    Dmart.token = 'tok';
    await Dmart.verifyContact(VerifyContactRequest(msisdn: '9647701234567', code: '123456'));
    expect(only().data, {'msisdn': '9647701234567', 'code': '123456'});
  });
}
