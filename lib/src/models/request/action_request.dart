import 'package:dmart/src/enums/request_type.dart';
import 'package:dmart/src/enums/resource_type.dart';

/// ActionRequest is a class that represents a request to the API to perform an action on a resource.
class ActionRequest {
  /// The name of the space in which the resource resides.
  final String spaceName;

  /// The type of request to perform.
  final RequestType requestType;

  /// The records to perform the action on.
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

/// ActionRequestRecord is a class that represents a record in an ActionRequest.
class ActionRequestRecord {
  /// The type of resource to perform the action on.
  final ResourceType resourceType;

  /// The shortname of the resource.
  String shortname;

  /// The subpath of the resource.
  final String subpath;

  /// The attributes to perform the action with.
  final Map<String, dynamic> attributes;

  /// The attachments to perform the action with.
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
