import 'package:dmart/src/enums/request_type.dart';
import 'package:dmart/src/enums/resource_type.dart';

class ActionRequest {
  final String spaceName;
  final RequestType requestType;
  final List<ActionRequestRecord> records;

  ActionRequest({
    required this.spaceName,
    required this.requestType,
    required this.records,
  });

  Map<String, dynamic> toJson() {
    return {
      'space_name': spaceName,
      'request_type': requestType.name,
      'records':
          records.map((ActionRequestRecord record) => record.toJson()).toList(),
    };
  }
}

class ActionRequestRecord {
  final ResourceType resourceType;
  String shortname;
  final String subpath;
  final Map<String, dynamic> attributes;
  final Map<ResourceType, List<dynamic>>? attachments;

  ActionRequestRecord({
    required this.resourceType,
    this.shortname = 'auto',
    required this.subpath,
    required this.attributes,
    this.attachments,
  });

  factory ActionRequestRecord.fromJson(Map<String, dynamic> json) {
    return ActionRequestRecord(
      resourceType: ResourceType.values.byName(json['resource_type']),
      shortname: json['shortname'],
      subpath: json['subpath'],
      attributes: Map<String, dynamic>.from(json['attributes']),
      attachments: json['attachments'] != null
          ? Map<ResourceType, List<dynamic>>.from(json['attachments'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "resource_type": resourceType.name,
      "shortname": shortname,
      "subpath": subpath,
      "attributes": attributes
    };
  }
}
