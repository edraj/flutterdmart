import 'package:dmart/src/enums/query_type.dart';
import 'package:dmart/src/enums/resource_type.dart';
import 'package:dmart/src/enums/sort_type.dart';

class QueryRequest {
  QueryType queryType;
  String spaceName;
  String subpath;
  String? search;
  List<ResourceType>? filterTypes;
  List<String>? filterSchemaNames;
  List<String>? filterShortnames;
  String? fromDate;
  String? toDate;
  String? sortBy;
  SortyType? sortType;
  bool? retrieveJsonPayload;
  bool? retrieveAttachments;
  bool? validateSchema;
  String? jqFilter;
  bool? exactSubpath;
  int? limit;
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

  Map<String, dynamic> toJson() {
    return {
      'type': queryType.toString().split('.').last,
      'space_name': spaceName,
      'subpath': subpath,
      'filter_types': filterTypes,
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
