import 'package:dmart/src/enums/resource_type.dart';

import '../enums/scope.dart';

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

  String url(Scope scope) =>
      '/${[scope.name, 'payload', resourceType.name, spaceName, subpath, shortname + schemaShortname + ext].join('/')}'
          .replaceAll(RegExp(r'/+'), '/');

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
