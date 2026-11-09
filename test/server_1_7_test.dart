// Routes, bodies and models that follow dmart 1.5–1.7.10.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dmart/dmart.dart';
import 'package:test/test.dart';

/// Records each request and answers its path from [routes]; any other path
/// gets a dmart success body.
class _Adapter implements HttpClientAdapter {
  _Adapter([this.routes = const {}]);

  final Map<String, (int, Object)> routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = routes[options.path] ?? (200, {'status': 'success'});
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _login(String type) => {
  'status': 'success',
  'records': [
    {
      'resource_type': 'user',
      'shortname': 'alice',
      'subpath': '/users',
      'attributes': {'access_token': 'tok', 'type': type},
    },
  ],
};

void main() {
  late _Adapter adapter;

  _Adapter serve([Map<String, (int, Object)> routes = const {}, String? deviceId]) {
    adapter = _Adapter(routes);
    Dmart.deviceId = null;
    Dmart.initDmart(dio: Dio(BaseOptions(baseUrl: 'http://dmart.test'))..httpClientAdapter = adapter, deviceId: deviceId);
    Dmart.token = null;
    return adapter;
  }

  RequestOptions only() {
    expect(adapter.requests, hasLength(1));
    return adapter.requests.single;
  }

  group('login', () {
    test('sends Dmart.deviceId as X-DeviceId when the request has none', () async {
      serve({'/user/login': (200, _login('mobile'))}, 'dev-1');
      final (res, err) = await Dmart.login(LoginRequest(shortname: 'alice', password: 'Secret1!'));
      expect(err, isNull);
      expect(res!.token, 'tok');
      final r = only();
      expect(r.headers['X-DeviceId'], 'dev-1');
      expect(r.data, {'shortname': 'alice', 'password': 'Secret1!'});
    });

    test('leaves the header out when the body carries device_id', () async {
      serve({'/user/login': (200, _login('mobile'))}, 'dev-1');
      await Dmart.login(LoginRequest(shortname: 'alice', password: 'Secret1!')..deviceID = 'dev-2');
      final r = only();
      expect(r.headers.containsKey('X-DeviceId'), isFalse);
      expect(r.data['device_id'], 'dev-2');
    });

    test('sends no X-DeviceId without a device id', () async {
      serve({'/user/login': (200, _login('web'))});
      await Dmart.login(LoginRequest(shortname: 'alice', password: 'Secret1!'));
      expect(only().headers.containsKey('X-DeviceId'), isFalse);
    });

    test('withPasswordAndOTP sends the identifier, password, code and device id', () async {
      serve({'/user/login': (200, _login('mobile'))});
      await Dmart.login(
        LoginRequest.withPasswordAndOTP(email: 'a@x.com', password: 'Secret1!', otp: '123456', deviceID: 'dev-1'),
      );
      expect(only().data, {'email': 'a@x.com', 'password': 'Secret1!', 'otp': '123456', 'device_id': 'dev-1'});
    });

    test('an OTP_NEEDED answer comes back as the error', () async {
      serve({
        '/user/login': (
          401,
          {
            'status': 'failed',
            'error': {'type': 'auth', 'code': 115, 'message': 'New device detected, login with otp'},
          },
        ),
      });
      final (res, err) = await Dmart.login(LoginRequest(shortname: 'alice', password: 'Secret1!'));
      expect(res, isNull);
      expect(err!.code, DmartErrorCode.otpNeeded);
    });

    test('reads an admin sign-in', () async {
      serve({'/user/login': (200, _login('admin'))});
      final (res, err) = await Dmart.login(LoginRequest(shortname: 'root', password: 'Secret1!'));
      expect(err, isNull);
      expect(res!.type, UserType.admin);
    });
  });

  test('createUser sends the chosen shortname and only what /user/create reads', () async {
    serve({'/user/create': (200, _login('web'))});
    await Dmart.createUser(
      CreateUserRequest(
        shortname: 'alice',
        attributes: CreateUserAttributes(
          displayname: Displayname(en: 'Alice'),
          email: 'a@x.com',
          password: 'Secret1!',
          emailOTP: '123456',
          // ignore: deprecated_member_use_from_same_package
          roles: ['super_admin'],
        ),
      ),
    );
    final r = only();
    expect(r.path, '/user/create');
    expect(r.data, {
      'shortname': 'alice',
      'attributes': {
        'displayname': {'en': 'Alice'},
        'email': 'a@x.com',
        'password': 'Secret1!',
        'email_otp': '123456',
      },
    });
  });

  test('verifyContact sends password and current_code', () async {
    serve();
    Dmart.token = 'tok';
    await Dmart.verifyContact(
      VerifyContactRequest(email: 'new@x.com', code: '111111', password: 'Secret1!', currentCode: '222222'),
    );
    expect(only().data, {'email': 'new@x.com', 'code': '111111', 'password': 'Secret1!', 'current_code': '222222'});
  });

  group('attach', () {
    test('posts to /public/attach without needing a token', () async {
      serve();
      final (res, err) = await Dmart.attach(
        spaceName: 'demo',
        record: Record(resourceType: 'comment', shortname: 'auto', subpath: 'posts/p1'),
      );
      expect(err, isNull);
      expect(res, isNotNull);
      final r = only();
      expect(r.path, '/public/attach/demo');
      expect(r.headers.containsKey('Authorization'), isFalse);
      final form = r.data as FormData;
      expect(jsonDecode(form.fields.singleWhere((f) => f.key == 'record').value)['shortname'], 'auto');
    });

    test('sends the token when there is one', () async {
      serve();
      Dmart.token = 'tok';
      await Dmart.attach(spaceName: 'demo', record: Record(resourceType: 'comment'));
      expect(only().headers['Authorization'], 'Bearer tok');
    });
  });

  test('getClientConfig reads /public/client-config', () async {
    serve({
      '/public/client-config': (
        200,
        {
          'status': 'success',
          'attributes': {
            'backend_timeout': 35000,
            'otp_length': 6,
            'otp_resend_after': 60,
            'otp_token_ttl': 300,
            'max_upload_size_mb': 50,
            'default_query_limit': 10,
            'max_query_limit': 10000,
            'ui_list_limit': 100,
            'password_rule_custom': true,
            'password_hint': 'At least 8 characters',
            'username_rule_custom': false,
          },
        },
      ),
    });
    final (config, err) = await Dmart.getClientConfig();
    expect(err, isNull);
    expect(config!.otpLength, 6);
    expect(config.backendTimeout, 35000);
    expect(config.defaultQueryLimit, 10);
    expect(config.passwordRuleCustom, isTrue);
    expect(config.passwordHint, 'At least 8 characters');
    expect(config.usernameRuleCustom, isFalse);
    expect(config.usernameHint, isNull);
    final r = only();
    expect(r.path, '/public/client-config');
    expect(r.headers.containsKey('Authorization'), isFalse);
  });

  group('query', () {
    test('reads total_is_lower_bound and sends no nulls', () async {
      serve({
        '/managed/query': (
          200,
          {
            'status': 'success',
            'records': [],
            'attributes': {'total': 100000, 'returned': 10, 'total_is_lower_bound': true},
          },
        ),
      });
      Dmart.token = 'tok';
      final (res, err) = await Dmart.query(QueryRequest(queryType: QueryType.search, spaceName: 'demo', subpath: '/'));
      expect(err, isNull);
      expect(res!.attributes!.totalIsLowerBound, isTrue);
      final body = only().data as Map<String, dynamic>;
      expect(body.containsKey('limit'), isFalse);
      expect(body.containsKey('validate_schema'), isFalse);
      expect(body.values, everyElement(isNotNull));
    });

    test('totalIsLowerBound defaults to false', () {
      expect(ApiQueryResponseAttributes.fromJson({'total': 3, 'returned': 3}).totalIsLowerBound, isFalse);
    });
  });

  test('getProfile reads the directory fields', () async {
    serve({
      '/user/profile': (
        200,
        {
          'status': 'success',
          'records': [
            {
              'resource_type': 'user',
              'shortname': 'u',
              'subpath': 'users',
              'attributes': {
                'type': 'admin',
                'language': 'english',
                'is_email_verified': true,
                'is_msisdn_verified': false,
                'force_password_change': false,
                'mailbox': 'u@corp.example',
                'mail_aliases': ['sales@corp.example'],
                'services': ['mail', 'vpn'],
              },
            },
          ],
        },
      ),
    });
    Dmart.token = 'tok';
    final (profile, err) = await Dmart.getProfile();
    expect(err, isNull);
    final attrs = profile!.records!.first.attributes;
    expect(attrs.mailbox, 'u@corp.example');
    expect(attrs.mailAliases, ['sales@corp.example']);
    expect(attrs.services, ['mail', 'vpn']);
  });

  test('ContentType knows binary', () {
    expect(ContentType.get('binary'), ContentType.binary);
    expect(Dmart.getMediaTypeFromDmartContentType(ContentType.binary), 'application/octet-stream');
  });
}
