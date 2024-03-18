import 'package:dmart/src/enums/resource_type.dart';

class RetrieveEntryRequest {
  final ResourceType resourceType;
  final String spaceName;
  final String subpath;
  final String shortname;
  final bool retrieveJsonPayload;
  final bool retrieveAttachments;
  final bool validateSchema;

  RetrieveEntryRequest({
    required this.resourceType,
    required this.spaceName,
    required this.subpath,
    required this.shortname,
    this.retrieveJsonPayload = false,
    this.retrieveAttachments = false,
    this.validateSchema = true,
  });
}
