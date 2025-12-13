import 'package:dmart/src/clients/base_client.dart';
import '../../dmart.dart';
import '../extensions/map_extension.dart';
import '../models/request/password_reset_request.dart';
import '../models/request/send_otp_request.dart';

/// Handles public (non-authenticated) API calls
class DmartPublicApi extends DmartHttpClient {
  DmartPublicApi(super.dio);

  Future<(dynamic, Error?)> checkExisting(CheckExistingParams params) {
    return execute(
      () => dio.get(
        '/user/check-existing',
        queryParameters: params.toQueryParams().withoutNulls(),
        options: buildOptions(),
      ),
      (data) => data,
    );
  }

  Future<LoginResponse> login(LoginRequest request) async {
    return await execute(
      () => dio.post('/user/login', data: request.toJson(), options: buildOptions()),
      (data) => LoginResponse.fromJson(data),
    );
  }

  Future<CreateUserResponse> createUser(CreateUserRequest request) {
    return execute(
      () => dio.post('/user/create', data: request.toJson().withoutNulls(), options: buildOptions()),
      (data) => CreateUserResponse.fromJson(data),
    );
  }

  Future<ApiResponse> otpRequest(SendOTPRequest request) {
    return execute(
      () => dio.post('/user/otp-request', data: request.toJson().withoutNulls(), options: buildOptions()),
      (data) => ApiResponse.fromJson(data),
    );
  }

  Future<ApiResponse> otpRequestLogin(SendOTPRequest request) {
    return execute(
      () => dio.post('/user/otp-request-login', data: request.toJson().withoutNulls(), options: buildOptions()),
      (data) => ApiResponse.fromJson(data),
    );
  }

  Future<ApiResponse> passwordResetRequest(PasswordResetRequest request) {
    return execute(
      () => dio.post('/user/password-reset-request', data: request.toJson().withoutNulls(), options: buildOptions()),
      (data) => ApiResponse.fromJson(data),
    );
  }

  Future<ActionResponse> submit(
    String spaceName,
    String schemaShortname,
    String subpath,
    String? resourceType,
    String? workflowShortname,
    Map<String, dynamic> record,
  ) {
    var url = '/public/submit/$spaceName';
    if (resourceType != null) url += '/$resourceType';
    if (workflowShortname != null) url += '/$workflowShortname';
    url += '/$schemaShortname/$subpath';

    return execute(() => dio.post(url, data: record, options: buildOptions()), (data) => ActionResponse.fromJson(data));
  }

  Future<ActionResponse> query(QueryRequest query, {Map<String, dynamic>? extra}) {
    query.sortType = query.sortType ?? SortyType.ascending;
    query.sortBy = query.sortBy ?? 'created_at';
    query.subpath = query.subpath.replaceAll(RegExp(r'/+'), '/');

    return execute(
      () => dio.post('/public/query', data: query.toJson(), options: buildOptions().copyWith(extra: extra)),
      (data) => ActionResponse.fromJson(data),
    );
  }
}
