import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/status.dart';

/// Base response class for Dmart API responses.
class ApiResponse {
  ApiResponse({required this.status, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] == 'success' ? Status.success : Status.failed,
      error: json['error'] != null ? DmartError.fromJson(json['error']) : null,
    );
  }
  final Status status;
  final DmartError? error;

  /// Converts the ApiResponse object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'status': status.name, 'error': error?.toJson()};
  }
}
