import 'package:dmart/src/models/api_response.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/query/response_record.dart';
import 'package:dmart/src/models/status.dart';

class ApiQueryResponse extends ApiResponse {
  final List<ResponseRecord> records;
  final ApiQueryResponseAttributes attributes;

  ApiQueryResponse({required super.status, super.error, required this.records, required this.attributes});

  factory ApiQueryResponse.fromJson(Map<String, dynamic> json) {
    return ApiQueryResponse(
      status: json['status'] == 'success' ? Status.success : Status.failed,
      error: json['error'] != null ? DmartError.fromJson(json['error']) : null,
      records: (json['records'] as List<dynamic>).map((record) => ResponseRecord.fromJson(record)).toList(),
      attributes: ApiQueryResponseAttributes.fromJson(Map<String, dynamic>.from(json['attributes'])),
    );
  }

  /// Converts the ApiQueryResponse object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status.name;
    if (error != null) {
      data['error'] = error!.toJson();
    }
    if (records.isNotEmpty) {
      data['records'] = records.map((record) => record.toJson()).toList();
    }
    data['attributes'] = attributes.toJson();
    return data;
  }
}

class ApiQueryResponseAttributes {
  final int total;
  final int returned;

  ApiQueryResponseAttributes({required this.total, required this.returned});

  factory ApiQueryResponseAttributes.fromJson(Map<String, dynamic> json) {
    return ApiQueryResponseAttributes(total: json['total'], returned: json['returned']);
  }

  /// Converts the ApiQueryResponseAttributes object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'total': total, 'returned': returned};
  }
}
