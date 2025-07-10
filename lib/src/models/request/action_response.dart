import 'package:dmart/src/enums/resource_type.dart';
import 'package:dmart/src/models/api_response.dart';
import 'package:dmart/src/models/attributes.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/query/response_record.dart';
import 'package:dmart/src/models/status.dart';

class ActionResponse extends ApiResponse {
  List<ActionResponseRecord>? records;
  Attributes? attributes;

  ActionResponse({required Status status, Error? error, this.records, this.attributes})
    : super(status: status, error: error);

  factory ActionResponse.fromJson(Map<String, dynamic> json) {
    ActionResponse actionResponse = ActionResponse(
      status: json['status'] == 'success' ? Status.success : Status.failed,
      error: json['error'] != null ? Error.fromJson(json['error']) : null, attributes: json['attributes'],
    );
    if (json['records'] != null) {
      actionResponse.records =
          (json['records'] as List<dynamic>)
              .map((record) => ActionResponseRecord.fromJson(record))
              .toList();
    }

    return actionResponse;
  }

  /// Converts the ActionResponse object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status.name;
    if (error != null) {
      data['error'] = error!.toJson();
    }
    if (records != null) {
      data['records'] = records!.map((record) => record.toJson()).toList();
    }
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    return data;
  }
}

class ActionResponseRecord extends ResponseRecord {
  late final ActionResponseAttachments? attachments;

  ActionResponseRecord({
    required super.resourceType,
    required super.uuid,
    required super.shortname,
    required super.subpath,
    required super.attributes,
  });

  factory ActionResponseRecord.fromJson(Map<String, dynamic> json) {
    var actionResponseRecord = ActionResponseRecord(
      resourceType: ResourceType.values.byName(json['resource_type']),
      uuid: json['uuid'],
      shortname: json['shortname'],
      subpath: json['subpath'],
      attributes: ResponseRecordAttributes.fromJson(json['attributes']),
    );
    if (json['attachments'] != null) {
      actionResponseRecord.attachments = ActionResponseAttachments.fromJson(json['attachments']);
    }
    return actionResponseRecord;
  }

  /// Converts the ActionResponseRecord object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resource_type'] = resourceType.name;
    data['uuid'] = uuid;
    data['shortname'] = shortname;
    data['subpath'] = subpath;
    data['attributes'] = attributes.toJson();
    if (attachments != null) {
      data['attachments'] = attachments!.toJson();
    }
    return data;
  }
}

class ActionResponseAttachments {
  final List<ResponseRecord>? media;
  final List<ResponseRecord>? json;

  ActionResponseAttachments({required this.media, required this.json});

  factory ActionResponseAttachments.fromJson(Map<String, dynamic> json) {
    return ActionResponseAttachments(
      media:
          (json['media'] as List<dynamic>?)
              ?.map((mediaRecord) => ResponseRecord.fromJson(mediaRecord))
              .toList(),
      json:
          (json['json'] as List<dynamic>?)
              ?.map((jsonRecord) => ResponseRecord.fromJson(jsonRecord))
              .toList(),
    );
  }

  /// Converts the ActionResponseAttachments object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['media'] = media?.map((record) => record.toJson()).toList();
    data['json'] = json?.map((record) => record.toJson()).toList();
    return data;
  }
}
