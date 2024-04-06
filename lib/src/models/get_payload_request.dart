import 'package:dmart/src/enums/resource_type.dart';

class GetPayloadRequest {
  final ResourceType resourceType;
  final String spaceName;
  final String subpath;
  final String shortname;
  final String ext;

  GetPayloadRequest({
    required this.resourceType,
    required this.spaceName,
    required this.subpath,
    required this.shortname,
    this.ext = '.json',
  });
}
