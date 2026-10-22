import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dmart/dmart.dart';
import 'package:test/test.dart';

/// Answers each path from [routes] with its status and body; any other path
/// gets a bare 404.
class _RoutesAdapter implements HttpClientAdapter {
  _RoutesAdapter(this.routes);

  final Map<String, (int, Object)> routes;
  final asked = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    asked.add(options.path);
    final (status, body) = routes[options.path] ?? (404, 'Not Found');
    final json = body is! String;
    return ResponseBody.fromString(
      json ? jsonEncode(body) : body,
      status,
      headers: {
        Headers.contentTypeHeader: [json ? Headers.jsonContentType : 'text/plain'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _map = {
  'demo:content:content': {
    'allowed_actions': ['view'],
    'conditions': [],
    'restricted_fields': [],
    'allowed_fields_values': {},
  },
};

Map<String, dynamic> _profile(Map<String, dynamic> attributes) => {
  'status': 'success',
  'records': [
    {
      'resource_type': 'user',
      'shortname': 'u',
      'subpath': 'users',
      'attributes': {
        'type': 'web',
        'language': 'english',
        'is_email_verified': true,
        'is_msisdn_verified': false,
        'force_password_change': false,
        ...attributes,
      },
    },
  ],
};

// What a dmart without the route sends: the unmatched-route rewrite.
const _invalidRoute = {
  'status': 'failed',
  'error': {'type': 'request', 'code': 230, 'message': 'Route not found: GET /user/permissions'},
};

void main() {
  _RoutesAdapter serve(Map<String, (int, Object)> routes) {
    final adapter = _RoutesAdapter(routes);
    Dmart.initDmart(dio: Dio(BaseOptions(baseUrl: 'http://dmart.test'))..httpClientAdapter = adapter);
    Dmart.token = 'tok';
    return adapter;
  }

  test('getPermissions reads /user/permissions', () async {
    final adapter = serve({
      '/user/permissions': (
        200,
        {
          'status': 'success',
          'attributes': {'permissions': _map},
        },
      ),
    });
    final (map, err) = await Dmart.getPermissions();
    expect(err, isNull);
    expect(map!.keys, ['demo:content:content']);
    expect(map['demo:content:content']!.allowedActions, [ActionType.view]);
    expect(adapter.asked, ['/user/permissions']);
  });

  for (final status in [422, 404]) {
    test('getPermissions falls back to the profile on a server without the route ($status)', () async {
      final adapter = serve({
        '/user/permissions': (status, _invalidRoute),
        '/user/profile': (200, _profile({'permissions': _map})),
      });
      final (map, err) = await Dmart.getPermissions();
      expect(err, isNull);
      expect(map!.keys, ['demo:content:content']);
      expect(adapter.asked, ['/user/permissions', '/user/profile']);
    });
  }

  test('a 404 without dmart\'s envelope also falls back', () async {
    final adapter = serve({
      '/user/profile': (200, _profile({'permissions': _map})),
    });
    final (map, err) = await Dmart.getPermissions();
    expect(err, isNull);
    expect(map!.keys, ['demo:content:content']);
    expect(adapter.asked, ['/user/permissions', '/user/profile']);
  });

  for (final (status, code) in [(401, 49), (422, 400)]) {
    test('getPermissions returns the error on any other failure ($status, code $code)', () async {
      final adapter = serve({
        '/user/permissions': (
          status,
          {
            'status': 'failed',
            'error': {'type': 'request', 'code': code, 'message': 'no'},
          },
        ),
      });
      final (map, err) = await Dmart.getPermissions();
      expect(map, isNull);
      expect(err!.code, code);
      expect(adapter.asked, ['/user/permissions']);
    });
  }

  test('getProfile reads a profile without a permission map', () async {
    serve({'/user/profile': (200, _profile({}))});
    final (profile, err) = await Dmart.getProfile();
    expect(err, isNull);
    expect(profile!.records!.first.attributes.permissions, isEmpty);
  });
}
