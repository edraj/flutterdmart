import 'package:dmart/src/models/record.dart';
import 'package:dmart/src/models/status.dart';

class BaseResponse {
  Status? status;
  List<Record>? records;

  BaseResponse({this.status, this.records});

  BaseResponse.fromJson(Map<String, dynamic> json) {
    status = Status.values.byName(json['status']);
    if (json['records'] != null) {
      records = <Record>[];
      json['records'].forEach((v) {
        records!.add(Record.fromJson(v));
      });
    }
  }

  /// Converts the BaseResponse object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (records != null) {
      data['records'] = records!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
