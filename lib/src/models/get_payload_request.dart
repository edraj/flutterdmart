import 'package:dmart/src/enums/resource_type.dart';

class GetPayloadRequest {
  final ResourceType resourceType;
  final String spaceName;
  final String subpath;
  final String shortname;
  final String schemaShortname;
  final String ext;

  GetPayloadRequest({
    required this.resourceType,
    required this.spaceName,
    required this.subpath,
    required this.shortname,
    this.schemaShortname = "",
    this.ext = '.json',
  });

  /// Converts the request to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'resource_type': resourceType.name,
      'space_name': spaceName,
      'subpath': subpath,
      'shortname': shortname,
      'schema_shortname': schemaShortname,
      'ext': ext,
    };
  }
}
