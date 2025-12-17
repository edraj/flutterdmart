import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmart/src/clients/base_client.dart';
import 'package:http_parser/http_parser.dart';
import '../../dmart.dart';
import '../enums/scope.dart';
import '../extensions/map_extension.dart';
import '../models/request/confirm_otp_request.dart';

/// Handles authenticated API calls
class DmartManagedApi extends DmartHttpClient {
  String _token;

  DmartManagedApi(super.dio, this._token);

  void updateToken(String newToken) {
    _token = newToken;
  }

  Options _buildAuthOptions({Map<String, dynamic>? extraHeaders}) {
    return Options(headers: {"content-type": "application/json", "Authorization": "Bearer $_token", ...?extraHeaders});
  }

  Future<ApiResponse> logout() {
    return execute(
      () => dio.post('/user/logout', data: {}, options: _buildAuthOptions()),
      (data) => ApiResponse.fromJson(data),
    );
  }

  Future<ApiResponse> confirmOTP(ConfirmOTPRequest request) {
    return execute(
      () => dio.post('/user/otp-confirm', data: request.toJson().withoutNulls(), options: _buildAuthOptions()),
      (data) => ApiResponse.fromJson(data),
    );
  }

  Future<ApiResponse> userReset(String shortname) {
    return execute(
      () => dio.post('/user/reset', data: {'shortname': shortname}, options: _buildAuthOptions()),
      (data) => ApiResponse.fromJson(data),
    );
  }

  Future<ApiResponse> validatePassword(String password) {
    return execute(
      () => dio.post('/user/validate_password', data: {'password': password}, options: _buildAuthOptions()),
      (data) => ApiResponse.fromJson(data),
    );
  }

  Future<ProfileResponse> getProfile() async {
    return await execute(
      () => dio.get('/user/profile', options: _buildAuthOptions()),
      (data) => ProfileResponse.fromJson(data),
    );
  }

  Future<ProfileResponse> updateProfile(ActionRequestRecord profile) async {
    return await execute(
      () => dio.post('/user/profile', data: profile.toJson(), options: _buildAuthOptions()),
      (data) => ProfileResponse.fromJson(data),
    );
  }

  Future<ActionResponse> query(QueryRequest query, {Scope scope = Scope.public, Map<String, dynamic>? extra}) {
    query.sortType = query.sortType ?? SortyType.ascending;
    query.sortBy = query.sortBy ?? 'created_at';
    query.subpath = query.subpath.replaceAll(RegExp(r'/+'), '/');

    return execute(
      () => dio.post('/${scope.name}/query', data: query.toJson(), options: _buildAuthOptions().copyWith(extra: extra)),
      (data) => ActionResponse.fromJson(data),
    );
  }

  Future<ActionResponse> request(ActionRequest action, {Scope scope = Scope.public}) {
    return execute(
      () => dio.post('/${scope.name}/request', data: action.toJson(), options: _buildAuthOptions()),
      (data) => ActionResponse.fromJson(data),
    );
  }

  Future<ResponseEntry> retrieveEntry(RetrieveEntryRequest request, {Scope scope = Scope.public}) {
    String subpath = request.subpath == "/" ? "__root__" : request.subpath;

    final url = '/${scope.name}/entry/${request.resourceType.name}/${request.spaceName}/$subpath/${request.shortname}'
            '?retrieve_json_payload=${request.retrieveJsonPayload}'
            '&retrieve_attachments=${request.retrieveAttachments}'
            '&validate_schema=${request.validateSchema}'
        .replaceAll(RegExp(r'/+'), '/');

    return execute(() => dio.get(url, options: _buildAuthOptions()), (data) => ResponseEntry.fromJson(data));
  }

  Future<ActionResponse> getSpaces() {
    return query(
      QueryRequest(queryType: QueryType.spaces, spaceName: "management", subpath: "/", search: "", limit: 100),
    );
  }

  Future<dynamic> getPayload(GetPayloadRequest request, {Scope scope = Scope.public}) {
    return execute(
      () => dio.get(
        '/$scope/payload/${request.resourceType.name}/${request.spaceName}/${request.subpath}/${request.shortname}${request.schemaShortname}${request.ext}',
        options: _buildAuthOptions(),
      ),
      (data) => ResponseEntry.fromJson(data),
    );
  }

  Future<ApiQueryResponse> progressTicket(ProgressTicketRequest request, {Scope scope = Scope.public}) {
    return execute(
      () => dio.put(
        '/${scope.name}/progress-ticket/${request.spaceName}/${request.subpath}/${request.shortname}/${request.action}',
        data: {'resolution': request.resolution, 'comment': request.comment},
        options: _buildAuthOptions(),
      ),
      (data) => ApiQueryResponse.fromJson(data),
    );
  }

  Future<dynamic> createAttachment({
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
    Map<String, dynamic> payloadData = {
      'resource_type': resourceType,
      'shortname': attachmentShortname,
      'subpath': "$entitySubpath/$entityShortname",
      'attributes': {
        'is_active': isActive,
        "payload": {'content_type': contentType.name, 'body': {}},
      },
    };

    FormData formData = FormData();
    formData.files.add(
      MapEntry(
        'payload_file',
        await MultipartFile.fromFile(attachmentBinary.path, contentType: MediaType.parse(contentType.getMediaType)),
      ),
    );
    formData.files.add(
      MapEntry(
        'request_record',
        MultipartFile.fromBytes(utf8.encode(json.encode(payloadData)), filename: 'payload.json'),
      ),
    );
    formData.fields.add(MapEntry('space_name', spaceName));

    return execute(
      () => dio.post(
        '/${scope.name}/resource_with_payload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {"content-type": "application/json", "Authorization": "Bearer $_token"},
        ),
      ),
      (data) => ResponseEntry.fromJson(data),
    );
  }

  Future<dynamic> getManifest() {
    return execute(() => dio.get('/info/manifest', options: _buildAuthOptions()), (data) => data);
  }

  Future<dynamic> getSettings() {
    return execute(() => dio.get('/info/settings', options: _buildAuthOptions()), (data) => data);
  }
}
