import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmart/src/enums/content_type.dart' as DmartContentType;
import 'package:dmart/src/enums/query_type.dart';
import 'package:dmart/src/enums/sort_type.dart';
import 'package:dmart/src/exceptions.dart';
import 'package:dmart/src/models/api_response.dart';
import 'package:dmart/src/models/create_user_model.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/get_payload_request.dart';
import 'package:dmart/src/models/login_model.dart';
import 'package:dmart/src/models/profile/profile_response.dart';
import 'package:dmart/src/models/progress_ticket_request.dart';
import 'package:dmart/src/models/query/query_request.dart';
import 'package:dmart/src/models/query/query_response.dart';
import 'package:dmart/src/models/request/action_request.dart';
import 'package:dmart/src/models/request/action_response.dart';
import 'package:dmart/src/models/response_entry.dart';
import 'package:dmart/src/models/retrieve_entry_request.dart';
import 'package:dmart/src/models/status.dart';
import 'package:http_parser/http_parser.dart';

/// Dmart class that has all the methods to interact with the Dmart server.
class Dmart {
  /// The base url of the Dmart server.
  static String dmartServerUrl = "localhost:8282";

  /// The token that is used for authentication.
  static String? token;

  /// The instance of the Dio class.
  static Dio? _dioInstance;

  /// The instance of the Dio class.
  static Dio get _dio {
    if (_dioInstance == null) {
      throw DmartException(DmartExceptionEnum.NOT_INITIALIZED,
          DmartExceptionMessages.messages[DmartExceptionEnum.NOT_INITIALIZED]!);
    }
    return _dioInstance!;
  }

  static final Map<String, dynamic> headers = {
    "content-type": "application/json"
  };

  static Error _returnExceptionError(DioException e) {
    if (e.response?.data?["error"] != null) {
      return Error.fromJson(e.response?.data["error"]);
    }

    return Error(
      type: 'unknown',
      code: 0,
      info: [],
      message: e.message.toString(),
    );
  }

  static void _isTokenNull() {
    if (token == null) {
      throw DmartException(DmartExceptionEnum.NOT_VALID_TOKEN,
          DmartExceptionMessages.messages[DmartExceptionEnum.NOT_VALID_TOKEN]!);
    }
  }

  static String getMediaTypeFromDmartContentType(
      DmartContentType.ContentType contentType) {
    switch (contentType) {
      case DmartContentType.ContentType.image:
        return "image/*";
      case DmartContentType.ContentType.text:
        return "text/*";
      case DmartContentType.ContentType.html:
        return "text/html";
      case DmartContentType.ContentType.markdown:
        return "text/markdown";
      case DmartContentType.ContentType.json:
        return "application/json";
      case DmartContentType.ContentType.python:
        return "application/*";
      case DmartContentType.ContentType.pdf:
        return "application/pdf";
      case DmartContentType.ContentType.audio:
        return "audio/*";
      case DmartContentType.ContentType.video:
        return "video/*";
      case DmartContentType.ContentType.jsonl:
        return "application/octet-stream";
      case DmartContentType.ContentType.csv:
        return "text/csv";
      case DmartContentType.ContentType.sqlite:
        return "application/octet-stream";
      case DmartContentType.ContentType.parquet:
        return "application/octet-stream";
    }
  }

  /// Initializes the Dmart class with the base url of the Dmart server.
  /// `dio` is used to override the default instance of Dio.
  /// `dioConfig` is used to override the default configuration of Dio.
  /// `interceptors` is used to override the default interceptors of Dio.
  /// `isDioVerbose` is used to enable the verbose mode of Dio.
  static void initDmart({
    Dio? dio,
    BaseOptions? dioConfig,
    Iterable<Interceptor> interceptors = const [],
    bool isDioVerbose = false,
  }) async {
    if (dio != null) {
      _dioInstance = dio;
      if (dioConfig != null) {
        print('[WARNING] setting dioConfig will be ignored as dio is provided!');
      }
    } else {
      if (dioConfig != null) {
        dioConfig = BaseOptions(
          baseUrl: dmartServerUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        );
      }

      _dioInstance = Dio(dioConfig);
    }

    if (isDioVerbose) {
      _dioInstance?.interceptors.add(
        LogInterceptor(
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
        ),
      );
      _dioInstance?.interceptors.add(
        LogInterceptor(
          logPrint: (o) => print(o.toString()),
        ),
      );
    }

    _dioInstance?.interceptors.addAll(interceptors);
  }

  /// Logs in the user with the given [loginRequest].
  static Future<(LoginResponse?, Error?)> login(
    LoginRequest loginRequest,
  ) async {
    try {
      final response = await _dio.post(
        '/user/login',
        data: loginRequest.toJson(),
        options: Options(headers: headers),
      );
      var loginResponse = LoginResponse.fromJson(response.data);
      token = loginResponse.token;
      return (loginResponse, null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Creates a user with the given [createUserRequest].
  static Future<(CreateUserResponse?, Error?)> createUser(
      CreateUserRequest createUserRequest) async {
    try {
      final response = await _dio.post(
        '/user/create',
        data: createUserRequest.toJson(),
        options: Options(headers: headers),
      );
      return (CreateUserResponse.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Logs out the user.
  static Future<(ApiResponse?, Error?)> logout() async {
    _isTokenNull();
    try {
      final response = await _dio.post(
        '/user/logout',
        data: {},
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );

      return (ApiResponse.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Retrieves the profile of the user.
  static Future<(ProfileResponse?, Error?)> getProfile() async {
    _isTokenNull();
    try {
      final response = await _dio.get(
        '/user/profile',
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );

      final profileResponse = ProfileResponse.fromJson(response.data);
      if (profileResponse.status == Status.success &&
          profileResponse.records != null &&
          profileResponse.records!.isNotEmpty) {
        return (profileResponse, null);
      }

      return (
        null,
        Error(
            type: 'unknown',
            code: 0,
            info: [profileResponse.error?.toJson() ?? {}],
            message: "Unable to retrieve the profile.")
      );
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Retrieves the user with the given [QueryRequest].
  static Future<(ApiQueryResponse?, Error?)> query(QueryRequest query,
      {String scope = "managed"}) async {
    if (token == null && scope == "managed") {
      throw DmartException(DmartExceptionEnum.NOT_VALID_TOKEN,
          DmartExceptionMessages.messages[DmartExceptionEnum.NOT_VALID_TOKEN]!);
    }
    try {
      query.sortType = query.sortType ?? SortyType.ascending;
      query.sortBy = query.sortBy ?? 'created_at';
      query.subpath = query.subpath.replaceAll(RegExp(r'/+'), '/');

      final response = await _dio.post(
        '/$scope/query',
        data: query.toJson(),
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );

      return (ApiQueryResponse.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Requests an action with the given [ActionRequest].
  static Future<(ActionResponse?, Error?)> request(ActionRequest action) async {
    _isTokenNull();
    try {
      final response = await _dio.post(
        '/managed/request',
        data: action.toJson(),
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );
      return (ActionResponse.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Retrieves the entry with the given [RetrieveEntryRequest].
  static Future<(ResponseEntry?, Error?)> retrieveEntry(
      RetrieveEntryRequest request,
      {String scope = "managed"}) async {
    if (token == null && scope == "managed") {
      throw DmartException(DmartExceptionEnum.NOT_VALID_TOKEN,
          DmartExceptionMessages.messages[DmartExceptionEnum.NOT_VALID_TOKEN]!);
    }
    String? subpath = request.subpath;
    try {
      if (subpath == "/") subpath = "__root__";
      final response = await _dio.get(
        '/$scope/entry/${request.resourceType.name}/${request.spaceName}/${request.subpath}/${request.shortname}?retrieve_json_payload=${request.retrieveJsonPayload}&retrieve_attachments=${request.retrieveAttachments}&validate_schema=${request.validateSchema}'
            .replaceAll(RegExp(r'/+'), '/'),
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );

      return (ResponseEntry.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Creates a space with the given [ActionRequest].
  static Future<(ActionResponse?, Error?)> createSpace(
    ActionRequest action,
  ) async {
    _isTokenNull();
    try {
      final response = await _dio.post(
        '/managed/space',
        data: action.toJson(),
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );
      return (ActionResponse.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Retrieves the spaces.
  static Future<(ApiQueryResponse?, Error?)> getSpaces() async {
    return await query(QueryRequest(
      queryType: QueryType.spaces,
      spaceName: "management",
      subpath: "/",
      search: "",
      limit: 100,
    ));
  }

  /// Retrieves the space with the given [GetPayloadRequest].
  static Future<dynamic> getPayload(GetPayloadRequest request) async {
    _isTokenNull();
    try {
      final response = await _dio.get(
        '/managed/payload/${request.resourceType.name}/${request.spaceName}/${request.subpath}/${request.shortname}${request.ext}',
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );

      return (ResponseEntry.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Progresses the ticket with the given [ProgressTicketRequest].
  static Future<(ApiQueryResponse?, Error?)> progressTicket(
    ProgressTicketRequest request,
  ) async {
    _isTokenNull();
    try {
      final response = await _dio.put(
        '/managed/progress-ticket/${request.spaceName}/${request.subpath}/${request.shortname}/${request.action}',
        data: {
          'resolution': request.resolution,
          'comment': request.comment,
        },
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );

      return (ApiQueryResponse.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Creates an attachment
  /// providing [spaceName], [entitySubpath], [entityShortname], [attachmentShortname], [attachmentBinary], [resourceType] and [isActive].
  static Future<(dynamic, Error?)> createAttachment({
    required String spaceName,
    required String entitySubpath,
    required String entityShortname,
    required String attachmentShortname,
    required File attachmentBinary,
    DmartContentType.ContentType contentType =
        DmartContentType.ContentType.image,
    String resourceType = "media",
    bool isActive = true,
  }) async {
    _isTokenNull();

    Map<String, dynamic> payloadData = {
      'resource_type': resourceType,
      'shortname': attachmentShortname,
      'subpath': "$entitySubpath/$entityShortname",
      'attributes': {
        'is_active': isActive,
        "payload": {
          'content_type': contentType.name,
          'body': {},
        },
      },
    };
    var payloadJson = json.encode(payloadData);

    FormData formData = FormData();
    formData.files.add(
      MapEntry(
        'payload_file',
        await MultipartFile.fromFile(
          attachmentBinary.path,
          contentType:
              MediaType.parse(getMediaTypeFromDmartContentType(contentType)),
        ),
      ),
    );
    formData.files.add(
      MapEntry(
        'request_record',
        MultipartFile.fromBytes(utf8.encode(payloadJson),
            filename: 'payload.json'),
      ),
    );
    formData.fields.add(MapEntry('space_name', spaceName));

    try {
      Response? response = await _dio.post(
        '/managed/resource_with_payload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {...headers, "Authorization": "Bearer $token"},
        ),
      );

      return (ResponseEntry.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Submits a record with the given [spaceName], [schemaShortname], [subpath], and [record].
  static Future<(ActionResponse?, Error?)> submit(
    String spaceName,
    String schemaShortname,
    String subpath,
    Map<String, dynamic> record,
  ) async {
    try {
      final response = await _dio.post(
        '/public/submit/$spaceName/$schemaShortname/$subpath',
        data: record,
        options: Options(headers: headers),
      );
      return (ActionResponse.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Constructs the attachment url with the given [resourceType], [spaceName], [entitySubpath], [entityShortname], [attachmentShortname], and [ext].
  static String getAttachmentUrl(
    String resourceType,
    String spaceName,
    String entitySubpath,
    String entityShortname,
    String attachmentShortname,
    String ext,
  ) {
    return '$dmartServerUrl/managed/payload/$resourceType/$spaceName/${entitySubpath.replaceAll(RegExp(r'/+$'), '')}/$entityShortname/$attachmentShortname.$ext'
        .replaceAll('..', '.');
  }

  /// Retrieves the manifest.
  static Future<dynamic> getManifest() async {
    try {
      final response = await _dio.get(
        '/info/manifest',
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );
      return (response.data, null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }

  /// Retrieves the settings.
  static Future<dynamic> getSettings() async {
    try {
      final response = await _dio.get(
        '/info/settings',
        options:
            Options(headers: {...headers, "Authorization": "Bearer $token"}),
      );
      return (response.data, null);
    } on DioException catch (e) {
      return (null, _returnExceptionError(e));
    }
  }
}
