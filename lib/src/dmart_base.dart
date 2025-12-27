import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmart/src/exceptions.dart';
import 'package:http_parser/http_parser.dart';

import '../dmart.dart';
import 'enums/scope.dart';
import 'extensions/map_extension.dart';
import 'models/request/confirm_otp_request.dart';
import 'models/request/password_reset_request.dart';
import 'models/request/send_otp_request.dart';

/// Configuration for Dmart client
class DmartConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool verbose;
  final Map<String, dynamic>? headers;
  final Iterable<Interceptor> interceptors;

  const DmartConfig({
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

  late Dio _dio;
  late DmartConfig _config;
  String? _token;

  static Dio get dio {
    _ensureInitialized();
    return _instance._dio;
  }

  static DmartConfig get config => _instance._config;
  static bool get isAuthenticated => _instance._token != null;
  static String? get token {
    _ensureAuthenticated();
    return _instance._token;
  }

  static void init({Dio? dio, DmartConfig configuration = const DmartConfig()}) {
    _instance._config = configuration;

    final dioInstance =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: _instance._config.baseUrl,
            connectTimeout: _instance._config.connectTimeout,
            receiveTimeout: _instance._config.receiveTimeout,
          ),
        );

    if (_instance._config.verbose) {
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

    dioInstance.interceptors.addAll(_instance._config.interceptors);
    _instance._dio = dioInstance;
  }

  static void setToken(String token) => _instance._token = token;

  static void clearToken() => _instance._token = null;

  // ==================== Public Endpoints ====================

  static Future<dynamic> checkExisting(CheckExistingParams params) => _execute(
    () => dio.get(
      '/user/check-existing',
      queryParameters: params.toQueryParams().withoutNulls(),
      options: _buildOptions(),
    ),
    (data) => data,
  );

  static Future<LoginResponse> login(LoginRequest request) => _execute(
    () => dio.post('/user/login', data: request.toJson(), options: _buildOptions()),
    (data) => LoginResponse.fromJson(data),
  );

  static Future<CreateUserResponse> createUser(CreateUserRequest request) => _execute(
    () => dio.post('/user/create', data: request.toJson().withoutNulls(), options: _buildOptions()),
    (data) => CreateUserResponse.fromJson(data),
  );

  static Future<ApiResponse> otpRequest(SendOTPRequest request) => _execute(
    () => dio.post('/user/otp-request', data: request.toJson().withoutNulls(), options: _buildOptions()),
    (data) => ApiResponse.fromJson(data),
  );

  static Future<ApiResponse> otpRequestLogin(SendOTPRequest request) => _execute(
    () => dio.post('/user/otp-request-login', data: request.toJson().withoutNulls(), options: _buildOptions()),
    (data) => ApiResponse.fromJson(data),
  );

  static Future<ApiResponse> passwordResetRequest(PasswordResetRequest request) => _execute(
    () => dio.post('/user/password-reset-request', data: request.toJson().withoutNulls(), options: _buildOptions()),
    (data) => ApiResponse.fromJson(data),
  );

  static Future<ActionResponse<T>> submit<T>(
    String spaceName,
    String schemaShortname,
    String subpath,
    String? resourceType,
    String? workflowShortname,
    Map<String, dynamic> record, {
    Scope scope = Scope.public,
    T Function(dynamic)? parser,
  }) {
    String url =
        '/${[scope.name, 'submit', spaceName, if (resourceType != null) resourceType, if (workflowShortname != null) workflowShortname, schemaShortname, subpath].join('/')}';
    return _execute(
      () => dio.post(url, data: record, options: _buildOptions()),
      (data) => ActionResponse<T>.fromJson(data, parser),
    );
  }

  // ==================== Managed Endpoints ====================

  static Future<ApiResponse> logout() => _execute(
    () => dio.post('/user/logout', data: {}, options: _buildOptions()),
    (data) => ApiResponse.fromJson(data),
  );

  static Future<ApiResponse> confirmOTP(ConfirmOTPRequest request) => _execute(
    () => dio.post('/user/otp-confirm', data: request.toJson().withoutNulls(), options: _buildOptions()),
    (data) => ApiResponse.fromJson(data),
  );

  static Future<ApiResponse> userReset(String shortname) => _execute(
    () => dio.post('/user/reset', data: {'shortname': shortname}, options: _buildOptions()),
    (data) => ApiResponse.fromJson(data),
  );

  static Future<ApiResponse> validatePassword(String password) => _execute(
    () => dio.post('/user/validate_password', data: {'password': password}, options: _buildOptions()),
    (data) => ApiResponse.fromJson(data),
  );

  static Future<ProfileResponse> getProfile() =>
      _execute(() => dio.get('/user/profile', options: _buildOptions()), (data) => ProfileResponse.fromJson(data));

  static Future<ProfileResponse> updateProfile(ActionRequestRecord profile) => _execute(
    () => dio.post('/user/profile', data: profile.toJson(), options: _buildOptions()),
    (data) => ProfileResponse.fromJson(data),
  );

  static Future<ActionResponse<T>> query<T>(
    QueryRequest query, {
    Scope scope = Scope.public,
    Map<String, dynamic>? extra,
    T Function(dynamic)? parser,
  }) {
    query.subpath = query.subpath.replaceAll(RegExp(r'/+'), '/');

    return _execute(
      () => dio.post(buildScopedUrl(scope, 'query'), data: query.toJson(), options: _buildOptions(extraHeaders: extra)),
      (data) => ActionResponse<T>.fromJson(data, parser),
    );
  }

  static Future<ActionResponse<T>> request<T>(
    ActionRequest action, {
    Scope scope = Scope.managed,
    T Function(dynamic)? parser,
  }) => _execute(
    () => dio.post(buildScopedUrl(scope, 'request'), data: action.toJson(), options: _buildOptions()),
    (data) => ActionResponse<T>.fromJson(data, parser),
  );

  static Future<ResponseEntry> retrieveEntry(RetrieveEntryRequest request, {Scope scope = Scope.public}) =>
      _execute(() => dio.get(request.url(scope), options: _buildOptions()), (data) => ResponseEntry.fromJson(data));

  static Future<ActionResponse<dynamic>> getSpaces() => query<dynamic>(
    QueryRequest(queryType: QueryType.spaces, spaceName: "management", subpath: "/", search: "", limit: 100),
  );

  static Future<dynamic> getPayload(GetPayloadRequest request, {Scope scope = Scope.public}) =>
      _execute(() => dio.get(request.url(scope), options: _buildOptions()), (data) => ResponseEntry.fromJson(data));

  static Future<ApiQueryResponse> progressTicket(ProgressTicketRequest request, {Scope scope = Scope.public}) =>
      _execute(
        () => dio.put(
          request.url(scope),
          data: {'resolution': request.resolution, 'comment': request.comment},
          options: _buildOptions(),
        ),
        (data) => ApiQueryResponse.fromJson(data),
      );

  static Future<dynamic> createAttachment({
    required String spaceName,
    required String entitySubpath,
    required String entityShortname,
    required String attachmentShortname,
    required File attachmentBinary,
    ContentType contentType = ContentType.image,
    String resourceType = "media",
    bool isActive = true,
    Scope scope = Scope.public,
  }) async {
    final payloadData = {
      'resource_type': resourceType,
      'shortname': attachmentShortname,
      'subpath': "$entitySubpath/$entityShortname",
      'attributes': {
        'is_active': isActive,
        'payload': {'content_type': contentType.name, 'body': {}},
      },
    };

    final formData =
        FormData()
          ..files.add(
            MapEntry(
              'payload_file',
              await MultipartFile.fromFile(
                attachmentBinary.path,
                contentType: MediaType.parse(contentType.getMediaType),
              ),
            ),
          )
          ..files.add(
            MapEntry(
              'request_record',
              MultipartFile.fromBytes(utf8.encode(json.encode(payloadData)), filename: 'payload.json'),
            ),
          )
          ..fields.add(MapEntry('space_name', spaceName));

    return _execute(
      () => dio.post(
        buildScopedUrl(scope, 'resource_with_payload'),
        data: formData,
        options: _buildOptions(contentType: 'multipart/form-data'),
      ),
      (data) => ResponseEntry.fromJson(data),
    );
  }

  static Future<dynamic> getManifest() =>
      _execute(() => dio.get('/info/manifest', options: _buildOptions()), (data) => data);

  static Future<dynamic> getSettings() =>
      _execute(() => dio.get('/info/settings', options: _buildOptions()), (data) => data);

  // ==================== Private Helpers ====================

  static Future<T> _execute<T>(Future<Response> Function() request, T Function(dynamic) parser) async {
    try {
      final response = await request();
      return parser(response.data);
    } on DioException catch (e) {
      throw _parseDmartError(e);
    }
  }

  static DmartError _parseDmartError(DioException e) {
    if (e.response?.data?["error"] != null) {
      return DmartError.fromJson(e.response?.data["error"]);
    }
    return DmartError(type: 'unknown', code: 0, info: [], message: e.message ?? e.error.toString());
  }

  static Options _buildOptions({Map<String, dynamic>? extraHeaders, String? contentType}) {
    final baseHeaders = _instance._config.headers ?? {'content-type': contentType ?? 'application/json'};

    return Options(
      headers: {
        ...baseHeaders,
        ...?extraHeaders,
        if (_instance._token != null) 'Authorization': 'Bearer ${_instance._token}',
      },
    );
  }

  static String buildScopedUrl(Scope scope, String path) => '/${scope.name}/$path'.replaceAll(RegExp(r'/+'), '/');

  static void _ensureInitialized() {
    try {
      _instance._dio;
    } catch (e) {
      throw DmartException(
        DmartExceptionEnum.NOT_INITIALIZED,
        DmartExceptionMessages.messages[DmartExceptionEnum.NOT_INITIALIZED]!,
      );
    }
  }

  static void _ensureAuthenticated() {
    if (_instance._token == null) {
      throw DmartException(
        DmartExceptionEnum.NOT_VALID_TOKEN,
        DmartExceptionMessages.messages[DmartExceptionEnum.NOT_VALID_TOKEN]!,
      );
    }
  }
}
