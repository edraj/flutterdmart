import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmart/dmart.dart';
import 'package:dmart/src/extensions/map_extension.dart';
import 'package:http_parser/http_parser.dart';

/// Dmart client class providing methods to interact with the Dmart server.
///
/// All methods are static. Call [init] before using any other method.
/// Authentication is managed via [login] which stores the token internally.
///
/// Methods throw [DmartApiException] on API errors and [DmartException] on
/// client-side errors (e.g. missing initialization or token).
class Dmart {
  /// The base url of the Dmart server.
  static String dmartServerUrl = 'localhost:8282';

  /// The token that is used for authentication.
  static String? _token;

  /// Whether the client currently holds a valid token.
  static bool get isAuthenticated => _token != null;

  /// The current auth token (throws if not authenticated).
  static String get token {
    _requireToken();
    return _token!;
  }

  /// Sets the auth token explicitly (e.g. from stored session).
  static set token(String value) => _token = value;

  /// Clears the stored auth token.
  static void clearToken() => _token = null;

  // ignore: avoid_print
  static void _defaultLogPrint(String message) => print(message);

  static final RegExp _multiSlashRegExp = RegExp(r'/+');
  static final RegExp _trailingSlashRegExp = RegExp(r'/+$');

  static Dio? _dioInstance;

  static Dio get _dio {
    if (_dioInstance == null) {
      throw DmartException(
        DmartExceptionEnum.notInitialized,
        DmartExceptionMessages.messages[DmartExceptionEnum.notInitialized]!,
      );
    }
    return _dioInstance!;
  }

  // ==================== Initialization ====================

  /// Initializes the Dmart client.
  ///
  /// Must be called before any other method. Provide a custom [dio] instance
  /// or configure via [dioConfig]. Use [isDioVerbose] to enable request logging.
  static Future<void> init({
    Dio? dio,
    BaseOptions? dioConfig,
    Iterable<Interceptor> interceptors = const [],
    bool isDioVerbose = false,
    void Function(String) verboseLogPrint = _defaultLogPrint,
  }) async {
    if (dio != null) {
      _dioInstance = dio;
      dmartServerUrl = dio.options.baseUrl;
    } else {
      dioConfig ??= BaseOptions(
        baseUrl: dmartServerUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      );
      _dioInstance = Dio(dioConfig);
    }

    if (isDioVerbose) {
      _dioInstance?.interceptors.add(
        LogInterceptor(
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          logPrint: (o) => verboseLogPrint(o.toString()),
        ),
      );
    }

    _dioInstance?.interceptors.addAll(interceptors);
  }

  // ==================== Public Endpoints ====================

  /// Checks if a user exists by shortname, msisdn, or email.
  static Future<dynamic> checkExisting(CheckExistingParams params) => _execute(
    () => _dio.get(
      '/user/check-existing',
      queryParameters: params.toQueryParams().withoutNulls(),
      options: _options(),
    ),
    (data) => data,
  );

  /// Logs in the user and stores the token.
  static Future<LoginResponse> login(LoginRequest request) => _execute(
    () => _dio.post('/user/login', data: request.toJson(), options: _options()),
    (data) {
      final response = LoginResponse.fromJson(data);
      _token = response.token;
      return response;
    },
  );

  /// Creates a user account.
  static Future<CreateUserResponse> createUser(CreateUserRequest request) =>
      _execute(
        () => _dio.post(
          '/user/create',
          data: request.toJson().withoutNulls(),
          options: _options(),
        ),
        (data) => CreateUserResponse.fromJson(data),
      );

  /// Requests an OTP.
  static Future<ApiResponse> otpRequest(SendOTPRequest request) => _execute(
    () => _dio.post(
      '/user/otp-request',
      data: request.toJson().withoutNulls(),
      options: _options(),
    ),
    (data) => ApiResponse.fromJson(data),
  );

  /// Requests an OTP for login.
  static Future<ApiResponse> otpRequestLogin(SendOTPRequest request) =>
      _execute(
        () => _dio.post(
          '/user/otp-request-login',
          data: request.toJson().withoutNulls(),
          options: _options(),
        ),
        (data) => ApiResponse.fromJson(data),
      );

  /// Requests a password reset.
  static Future<ApiResponse> passwordResetRequest(
    PasswordResetRequest request,
  ) => _execute(
    () => _dio.post(
      '/user/password-reset-request',
      data: request.toJson().withoutNulls(),
      options: _options(),
    ),
    (data) => ApiResponse.fromJson(data),
  );

  /// Submits a record to a public endpoint.
  static Future<ActionResponse> submit(
    String spaceName,
    String schemaShortname,
    String subpath,
    String? resourceType,
    String? workflowShortname,
    Map<String, dynamic> record,
  ) {
    final segments = [
      'public',
      'submit',
      spaceName,
      if (resourceType != null) resourceType,
      if (workflowShortname != null) workflowShortname,
      schemaShortname,
      subpath,
    ];
    final url = '/${segments.join('/')}';

    return _execute(
      () => _dio.post(url, data: record, options: _options()),
      (data) => ActionResponse.fromJson(data),
    );
  }

  /// Retrieves the manifest (public, no auth required).
  static Future<dynamic> getManifest() => _execute(
    () => _dio.get('/info/manifest', options: _options()),
    (data) => data,
  );

  /// Retrieves the settings (public, no auth required).
  static Future<dynamic> getSettings() => _execute(
    () => _dio.get('/info/settings', options: _options()),
    (data) => data,
  );

  // ==================== Authenticated Endpoints ====================

  /// Logs out the user and clears the token.
  static Future<ApiResponse> logout() => _execute(
    () => _dio.post('/user/logout', data: {}, options: _options()),
    (data) {
      clearToken();
      return ApiResponse.fromJson(data);
    },
  );

  /// Confirms OTP.
  static Future<ApiResponse> confirmOTP(ConfirmOTPRequest request) => _execute(
    () => _dio.post(
      '/user/otp-confirm',
      data: request.toJson().withoutNulls(),
      options: _options(),
    ),
    (data) => ApiResponse.fromJson(data),
  );

  /// Resets a user by [shortname].
  static Future<ApiResponse> userReset(String shortname) => _execute(
    () => _dio.post(
      '/user/reset',
      data: {'shortname': shortname},
      options: _options(),
    ),
    (data) => ApiResponse.fromJson(data),
  );

  /// Validates the current user's password.
  static Future<ApiResponse> validatePassword(String password) => _execute(
    () => _dio.post(
      '/user/validate_password',
      data: {'password': password},
      options: _options(),
    ),
    (data) => ApiResponse.fromJson(data),
  );

  /// Retrieves the profile of the authenticated user.
  static Future<ProfileResponse> getProfile() =>
      _execute(() => _dio.get('/user/profile', options: _options()), (data) {
        final response = ProfileResponse.fromJson(data);
        if (response.status == Status.success &&
            response.records != null &&
            response.records!.isNotEmpty) {
          return response;
        }
        throw DmartApiException(
          DmartError(
            type: 'unknown',
            code: 0,
            info: [response.error?.toJson() ?? {}],
            message: 'Unable to retrieve the profile.',
          ),
        );
      });

  /// Updates the profile of the authenticated user.
  static Future<ProfileResponse> updateProfile(ActionRequestRecord profile) =>
      _execute(
        () => _dio.post(
          '/user/profile',
          data: profile.toJson(),
          options: _options(),
        ),
        (data) {
          final response = ProfileResponse.fromJson(data);
          if (response.status == Status.success) return response;
          throw DmartApiException(
            DmartError(
              type: 'unknown',
              code: 0,
              info: [response.error?.toJson() ?? {}],
              message: 'Unable to update the profile.',
            ),
          );
        },
      );

  /// Queries resources.
  static Future<ActionResponse> query(
    QueryRequest query, {
    Scope scope = Scope.managed,
    Map<String, dynamic>? extra,
  }) {
    query.subpath = query.subpath.replaceAll(_multiSlashRegExp, '/');

    return _execute(
      () => _dio.post(
        _scopedUrl(scope, 'query'),
        data: query.toJson(),
        options: _options(extra: extra),
      ),
      (data) => ActionResponse.fromJson(data),
    );
  }

  /// Performs a create/update/delete action.
  ///
  /// Returns `null` when [ActionRequest.requestType] is [RequestType.delete].
  static Future<ActionResponse?> request(
    ActionRequest action, {
    Scope scope = Scope.managed,
  }) => _execute(
    () => _dio.post(
      _scopedUrl(scope, 'request'),
      data: action.toJson(),
      options: _options(),
    ),
    (data) =>
        action.requestType == RequestType.delete
            ? null
            : ActionResponse.fromJson(data),
  );

  /// Retrieves a single entry.
  static Future<ResponseEntry> retrieveEntry(
    RetrieveEntryRequest request, {
    Scope scope = Scope.managed,
  }) {
    final subpath = request.subpath == '/' ? '__root__' : request.subpath;
    final url =
        '/${scope.name}/entry/${request.resourceType.name}/${request.spaceName}/$subpath/${request.shortname}'
        '?retrieve_json_payload=${request.retrieveJsonPayload}'
        '&retrieve_attachments=${request.retrieveAttachments}'
        '&validate_schema=${request.validateSchema}';

    return _execute(
      () =>
          _dio.get(url.replaceAll(_multiSlashRegExp, '/'), options: _options()),
      (data) => ResponseEntry.fromJson(data),
    );
  }

  /// Retrieves all spaces.
  static Future<ActionResponse> getSpaces() => query(
    QueryRequest(
      queryType: QueryType.spaces,
      spaceName: 'management',
      subpath: '/',
      search: '',
      limit: 100,
    ),
  );

  /// Retrieves the payload of an entry.
  static Future<dynamic> getPayload(
    GetPayloadRequest request, {
    Scope scope = Scope.managed,
  }) => _execute(
    () => _dio.get(
      '/${scope.name}/payload/${request.resourceType.name}/${request.spaceName}/${request.subpath}/${request.shortname}${request.schemaShortname}${request.ext}',
      options: _options(),
    ),
    (data) => data?['attributes'],
  );

  /// Progresses a ticket.
  static Future<ApiQueryResponse> progressTicket(
    ProgressTicketRequest request, {
    Scope scope = Scope.managed,
  }) => _execute(
    () => _dio.put(
      '/${scope.name}/progress-ticket/${request.spaceName}/${request.subpath}/${request.shortname}/${request.action}',
      data: {'resolution': request.resolution, 'comment': request.comment},
      options: _options(),
    ),
    (data) => ApiQueryResponse.fromJson(data),
  );

  /// Creates a binary attachment on an entity.
  static Future<ResponseEntry> createAttachment({
    required String spaceName,
    required String entitySubpath,
    required String entityShortname,
    required String attachmentShortname,
    required File attachmentBinary,
    ContentType contentType = ContentType.image,
    String resourceType = 'media',
    bool isActive = true,
    Scope scope = Scope.managed,
  }) async {
    final payloadData = {
      'resource_type': resourceType,
      'shortname': attachmentShortname,
      'subpath': '$entitySubpath/$entityShortname',
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
                contentType: MediaType.parse(contentType.mediaType),
              ),
            ),
          )
          ..files.add(
            MapEntry(
              'request_record',
              MultipartFile.fromBytes(
                utf8.encode(json.encode(payloadData)),
                filename: 'payload.json',
              ),
            ),
          )
          ..fields.add(MapEntry('space_name', spaceName));

    return _execute(
      () => _dio.post(
        _scopedUrl(scope, 'resource_with_payload'),
        data: formData,
        options: _options(contentType: 'multipart/form-data'),
      ),
      (data) => ResponseEntry.fromJson(data),
    );
  }

  /// Attaches a record (with optional file) to a space.
  static Future<ActionResponse> attach({
    required String spaceName,
    required Record record,
    File? payloadFile,
  }) async {
    final formData =
        FormData()
          ..fields.add(MapEntry('record', json.encode(record.toJson())));

    if (payloadFile != null) {
      formData.files.add(
        MapEntry(
          'payload_file',
          await MultipartFile.fromFile(payloadFile.path),
        ),
      );
    }

    return _execute(
      () => _dio.post(
        '/attach/$spaceName',
        data: formData,
        options: _options(contentType: 'multipart/form-data'),
      ),
      (data) => ActionResponse.fromJson(data),
    );
  }

  /// Constructs the public URL for an attachment.
  static String getAttachmentUrl(
    String resourceType,
    String spaceName,
    String entitySubpath,
    String entityShortname,
    String attachmentShortname,
    String ext, {
    Scope scope = Scope.managed,
  }) {
    final cleanSubpath = entitySubpath.replaceAll(_trailingSlashRegExp, '');
    return '$dmartServerUrl/${scope.name}/payload/$resourceType/$spaceName'
        '/$cleanSubpath/$entityShortname/$attachmentShortname.$ext';
  }

  // ==================== Private Helpers ====================

  /// Executes a Dio [request], parses the successful response with [parser],
  /// and throws [DmartApiException] on any [DioException].
  static Future<T> _execute<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await request();
      return parser(response.data);
    } on DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  /// Converts a [DioException] into a [DmartApiException].
  static DmartApiException _parseApiError(DioException e) {
    if (e.response?.data?['error'] != null) {
      return DmartApiException(DmartError.fromJson(e.response?.data['error']));
    }
    return DmartApiException(
      DmartError(
        type: 'unknown',
        code: 0,
        info: [],
        message: e.message ?? e.error.toString(),
      ),
    );
  }

  /// Builds [Options] with auth token included when available.
  static Options _options({
    String contentType = 'application/json',
    Map<String, dynamic>? extra,
  }) => Options(
    headers: {
      'content-type': contentType,
      if (_token != null) 'Authorization': 'Bearer $_token',
    },
    extra: extra,
  );

  /// Builds a scoped URL like `/managed/query`.
  static String _scopedUrl(Scope scope, String path) =>
      '/${scope.name}/$path'.replaceAll(_multiSlashRegExp, '/');

  static void _requireToken() {
    if (_token == null) {
      throw DmartException(
        DmartExceptionEnum.notValidToken,
        DmartExceptionMessages.messages[DmartExceptionEnum.notValidToken]!,
      );
    }
  }
}
