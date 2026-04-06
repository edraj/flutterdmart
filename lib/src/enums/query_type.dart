/// The type of query to perform against the Dmart API.
enum QueryType {
  search('search'),
  subpath('subpath'),
  events('events'),
  history('history'),
  tags('tags'),
  spaces('spaces'),
  counters('counters'),
  reports('reports'),
  attachments('attachments'),
  attachmentsAggregation('attachments_aggregation');

  const QueryType(this.jsonValue);

  /// The JSON-serializable string value for this query type.
  final String jsonValue;

  /// Creates a [QueryType] from a JSON string value.
  static QueryType fromJson(String value) =>
      values.firstWhere((e) => e.jsonValue == value);
}
