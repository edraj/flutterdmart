enum QueryType {
  search,
  subpath,
  events,
  history,
  tags,
  spaces,
  counters,
  reports,
  attachments,
  attachmentsAggregation;

  String get string => this == attachmentsAggregation ? "attachments_aggregation" : name;

  static QueryType byName(String name) => QueryType.values.byName(name);
}
