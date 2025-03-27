import 'package:dmart/src/enums/resource_type.dart';

/// RetrieveEntryRequest is a class that represents a request to the API to retrieve an entry from a resource.
class RetrieveEntryRequest {
  /// The type of resource to retrieve.
  final ResourceType resourceType;
  /// The name of the space in which the resource resides.
  final String spaceName;
  /// The subpath of the resource.
  final String subpath;
  /// The shortname of the resource.
  final String shortname;
  /// Whether to retrieve the JSON payload of the resource.
  final bool retrieveJsonPayload;
  /// Whether to retrieve the attachments of the resource.
  final bool retrieveAttachments;
  /// Whether to validate the schema of the resource.
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
