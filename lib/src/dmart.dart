import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmart/src/exceptions.dart';

import '../dmart.dart';
import 'clients/managed_client.dart';
import 'clients/public_client.dart';
import 'enums/scope.dart';
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

  late Dio _dio;
  late DmartConfig _config;
  String? _token;

  DmartPublicApi? _publicApi;
  DmartManagedApi? _managedApi;

  static Dio? get dio => _instance._dio;
  static DmartConfig? get config => _instance._config;
  static bool get isAuthenticated => _instance._token != null;
  static String? get token => _instance._token;

  static DmartPublicApi get public {
    _instance._ensureInitialized();
    return _instance._publicApi ??= DmartPublicApi(_instance._dio);
  }

  static DmartManagedApi get managed {
    _instance._ensureInitialized();
    _instance._ensureAuthenticated();
    return _instance._managedApi ??= DmartManagedApi(_instance._dio, _instance._token!);
  }

  static void init({Dio? dio, DmartConfig? configuration}) {
    _instance._config = configuration ?? DmartConfig();

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

  static void setToken(String token) {
    _instance._token = token;
    _instance._managedApi = DmartManagedApi(_instance._dio, _instance._token!);
  }

  static void clearToken() {
    _instance._token = null;
    _instance._managedApi = null;
  }

  void _ensureInitialized() {
    try {
      _dio;
    } catch (e) {
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

  // Forwarding methods to public
  static Future<(dynamic, Error?)> checkExisting(CheckExistingParams params) => public.checkExisting(params);

  static Future<LoginResponse> login(LoginRequest request) => public.login(request);

  static Future<CreateUserResponse> createUser(CreateUserRequest request) => public.createUser(request);

  static Future<ApiResponse> otpRequest(SendOTPRequest request) => public.otpRequest(request);

  static Future<ApiResponse> otpRequestLogin(SendOTPRequest request) => public.otpRequestLogin(request);

  static Future<ApiResponse> passwordResetRequest(PasswordResetRequest request) => public.passwordResetRequest(request);

  static Future<ActionResponse> submit(
    String spaceName,
    String schemaShortname,
    String subpath,
    String? resourceType,
    String? workflowShortname,
    Map<String, dynamic> record, {
    Scope scope = Scope.public,
  }) => public.submit(spaceName, schemaShortname, subpath, resourceType, workflowShortname, record, scope: scope);

  static Future<ActionResponse> query(QueryRequest query, {Map<String, dynamic>? extra, Scope scope = Scope.public}) =>
      managed.query(query, extra: extra, scope: scope);

  // Managed (authenticated) forwarding methods
  static void updateToken(String newToken) => managed.updateToken(newToken);

  static Future<ApiResponse> logout() => managed.logout();

  static Future<ApiResponse> confirmOTP(ConfirmOTPRequest request) => managed.confirmOTP(request);

  static Future<ApiResponse> userReset(String shortname) => managed.userReset(shortname);

  static Future<ApiResponse> validatePassword(String password) => managed.validatePassword(password);

  static Future<ProfileResponse> getProfile() => managed.getProfile();

  static Future<ProfileResponse> updateProfile(ActionRequestRecord profile) => managed.updateProfile(profile);

  static Future<ActionResponse> request(ActionRequest action, {Scope scope = Scope.public}) =>
      managed.request(action, scope: scope);

  static Future<ResponseEntry> retrieveEntry(RetrieveEntryRequest request, {Scope scope = Scope.public}) =>
      managed.retrieveEntry(request, scope: scope);

  static Future<ActionResponse> getSpaces() => managed.getSpaces();

  static Future<dynamic> getPayload(GetPayloadRequest request, {Scope scope = Scope.public}) =>
      managed.getPayload(request, scope: scope);

  static Future<ApiQueryResponse> progressTicket(ProgressTicketRequest request, {Scope scope = Scope.public}) =>
      managed.progressTicket(request, scope: scope);

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
  }) => managed.createAttachment(
    spaceName: spaceName,
    entitySubpath: entitySubpath,
    entityShortname: entityShortname,
    attachmentShortname: attachmentShortname,
    attachmentBinary: attachmentBinary,
    contentType: contentType,
    resourceType: resourceType,
    isActive: isActive,
    scope: scope,
  );

  static Future<dynamic> getManifest() => managed.getManifest();

  static Future<dynamic> getSettings() => managed.getSettings();
}
