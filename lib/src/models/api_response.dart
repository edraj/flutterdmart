import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/status.dart';

class ApiResponse<T> {
  final Status status;
  final DmartError? error;

  ApiResponse({required this.status, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] == 'success' ? Status.success : Status.failed,
      error: json['error'] != null ? DmartError.fromJson(json['error']) : null,
    );
  }

  /// Converts the ApiResponse object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'status': status.name, 'error': error?.toJson()};
  }
}
