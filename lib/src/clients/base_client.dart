import 'package:dio/dio.dart';
import '../models/error.dart';

/// Base class for handling HTTP requests with common error handling
abstract class DmartHttpClient {
  final Dio dio;

  DmartHttpClient(this.dio);

  /// Execute a request with automatic error handling
  Future<T> execute<T>(Future<Response> Function() request, T Function(dynamic) parser) async {
    try {
      final response = await request();
      return parser(response.data);
    } on DioException catch (e) {
      throw parseError(e);
    }
  }

  Error parseError(DioException e) {
    if (e.response?.data?["error"] != null) {
      return Error.fromJson(e.response?.data["error"]);
    }
    return Error(type: 'unknown', code: 0, info: [], message: e.message ?? e.error.toString());
  }

  Options buildOptions({Map<String, dynamic>? extraHeaders}) {
    return Options(headers: {"content-type": "application/json", ...?extraHeaders});
  }
}
