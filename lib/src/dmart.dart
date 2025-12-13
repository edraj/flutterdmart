import 'package:dio/dio.dart';
import 'package:dmart/src/exceptions.dart';

import 'clients/managed_client.dart';
import 'clients/public_client.dart';

/// Configuration for Dmart client
class DmartConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool verbose;
  Map<String, dynamic>? headers;
  Iterable<Interceptor> interceptors;

  DmartConfig({
    this.baseUrl = "localhost:8282",
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.interceptors = const [],
    this.verbose = false,
    this.headers,
  });
}

/// Main Dmart client (Singleton)
class Dmart {
  Dmart._();

  static final Dmart _instance = Dmart._();

  Dio? _dio;
  String? _token;

  DmartPublicApi? _publicApi;
  DmartManagedApi? _managedApi;

  static Dio? get dio => _instance._dio;
  static bool get isAuthenticated => _instance._token != null;
  static String? get token => _instance._token;

  static DmartPublicApi get public {
    _instance._ensureInitialized();
    return _instance._publicApi ??= DmartPublicApi(_instance._dio!);
  }

  static DmartManagedApi get managed {
    _instance._ensureInitialized();
    _instance._ensureAuthenticated();
    return _instance._managedApi ??= DmartManagedApi(_instance._dio!, _instance._token!);
  }

  static void init({Dio? dio, DmartConfig? config}) {
    config ??= DmartConfig();

    final dioInstance =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
          ),
        );

    if (config.verbose) {
      dioInstance.interceptors.add(
        LogInterceptor(
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          logPrint: (o) => print(o),
        ),
      );
    }

    dioInstance.interceptors.addAll(config.interceptors);

    _instance._dio = dioInstance;
  }

  static void setToken(String token) {
    _instance._token = token;
    _instance._managedApi = DmartManagedApi(_instance._dio!, _instance._token!);
  }

  static void clearToken() {
    _instance._token = null;
    _instance._managedApi = null;
  }

  void _ensureInitialized() {
    if (_dio == null) {
      throw DmartException(
        DmartExceptionEnum.NOT_INITIALIZED,
        DmartExceptionMessages.messages[DmartExceptionEnum.NOT_INITIALIZED]!,
      );
    }
  }

  void _ensureAuthenticated() {
    if (_token == null) {
      throw DmartException(
        DmartExceptionEnum.NOT_VALID_TOKEN,
        DmartExceptionMessages.messages[DmartExceptionEnum.NOT_VALID_TOKEN]!,
      );
    }
  }
}
