import 'package:dmart/src/enums/query_type.dart';
import 'package:dmart/src/enums/resource_type.dart';
import 'package:dmart/src/enums/sort_type.dart';

/// QueryRequest is a class that represents a request to the API to query resources.
class QueryRequest {
  /// The type of query to perform.
  QueryType queryType;

  /// The name of the space in which the resources reside.
  String spaceName;

  /// The subpath of the resources.
  String subpath;

  /// The search query to filter the resources by.
  String? search;

  /// The types of resources to filter by.
  List<ResourceType>? filterTypes;

  /// The schema names of the resources to filter by.
  List<String>? filterSchemaNames;

  /// The shortnames of the resources to filter by.
  List<String>? filterShortnames;

  /// The date to filter the resources from.
  String? fromDate;

  /// The date to filter the resources to.
  String? toDate;

  /// The attribute to sort the resources by.
  String? sortBy;

  /// The type of sort to perform.
  SortyType? sortType;

  /// Whether to retrieve the JSON payload of the resources.
  bool? retrieveJsonPayload;

  /// Whether to retrieve the attachments of the resources.
  bool? retrieveAttachments;

  /// Whether to validate the schema of the resources.
  bool? validateSchema;

  /// The jq filter to apply to the resources.
  String? jqFilter;

  /// Whether to filter the resources by the exact subpath.
  bool? exactSubpath;

  /// The number of resources to retrieve.
  int? limit;

  /// The offset of the resources to retrieve.
  int? offset;

  QueryRequest({
    required this.queryType,
    required this.spaceName,
    required this.subpath,
    this.search,
    this.filterTypes,
    this.filterSchemaNames,
    this.filterShortnames,
    this.fromDate,
    this.toDate,
    this.sortBy,
    this.sortType,
    this.retrieveJsonPayload,
    this.retrieveAttachments,
    this.validateSchema,
    this.jqFilter,
    this.exactSubpath,
    this.limit,
    this.offset,
  });

  /// Converts the QueryRequest object to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'type': queryType.string,
      'space_name': spaceName,
      'subpath': subpath,
      'filter_types': filterTypes?.map((type) => type.toString().split('.').last).toList(),
      'filter_schema_names': filterSchemaNames,
      'filter_shortnames': filterShortnames,
      'search': search,
      'from_date': fromDate,
      'to_date': toDate,
      'sort_by': sortBy,
      'sort_type': sortType?.toString().split('.').last,
      'retrieve_json_payload': retrieveJsonPayload,
      'retrieve_attachments': retrieveAttachments,
      'validate_schema': validateSchema,
      'jq_filter': jqFilter,
      'exact_subpath': exactSubpath,
      'limit': limit,
      'offset': offset,
    }..removeWhere((key, value) => value == null);
  }
}
