import 'package:dmart/src/enums/resource_type.dart';
import 'package:dmart/src/models/payload.dart';
import 'package:dmart/src/models/translation.dart';

class ResponseRecord {
  final ResourceType resourceType;
  final String uuid;
  final String shortname;
  final String subpath;
  final ResponseRecordAttributes attributes;

  ResponseRecord({
    required this.resourceType,
    required this.uuid,
    required this.shortname,
    required this.subpath,
    required this.attributes,
  });

  factory ResponseRecord.fromJson(Map<String, dynamic> json) {
    return ResponseRecord(
      resourceType: ResourceType.values.byName(json['resource_type']),
      uuid: json['uuid'],
      shortname: json['shortname'],
      subpath: json['subpath'],
      attributes: ResponseRecordAttributes.fromJson(
        Map<String, dynamic>.from(json['attributes']),
      ),
    );
  }

  /// Converts the ResponseRecord object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resource_type'] = resourceType.name;
    data['uuid'] = uuid;
    data['shortname'] = shortname;
    data['subpath'] = subpath;
    data['attributes'] = attributes.toJson();
    return data;
  }
}

class ResponseRecordAttributes {
  final bool isActive;
  Translation? displayname;
  Translation? description;
  final Set<String> tags;
  final String createdAt;
  final String updatedAt;
  final String ownerShortname;
  final Payload? payload;

  ResponseRecordAttributes({
    required this.isActive,
    this.displayname,
    this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerShortname,
    this.payload,
  });

  factory ResponseRecordAttributes.fromJson(Map<String, dynamic> json) {
    ResponseRecordAttributes responseRecordAttributes =
        ResponseRecordAttributes(
          isActive: json['is_active'],
          tags: Set<String>.from(json['tags'] ?? []),
          createdAt: json['created_at'],
          updatedAt: json['updated_at'],
          ownerShortname: json['owner_shortname'],
          payload:
              json['payload'] != null
                  ? Payload.fromJson(Map<String, dynamic>.from(json['payload']))
                  : null,
        );

    if (json['displayname'] != null) {
      responseRecordAttributes.displayname = Translation.fromJson(
        Map<String, dynamic>.from(json['displayname']),
      );
    }

    if (json['description'] != null) {
      responseRecordAttributes.description = Translation.fromJson(
        Map<String, dynamic>.from(json['description'] ?? {}),
      );
    }

    return responseRecordAttributes;
  }

  /// Converts the responseRecordAttributes object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_active'] = isActive;
    if (displayname != null) {
      data['displayname'] = displayname!.toJson();
    }
    if (description != null) {
      data['description'] = description!.toJson();
    }
    data['tags'] = tags.toList();
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['owner_shortname'] = ownerShortname;
    if (payload != null) {
      data['payload'] = payload!.toJson();
    }
    return data;
  }
}
