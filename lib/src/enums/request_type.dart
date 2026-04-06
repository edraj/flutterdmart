/// The type of request to perform on a resource.
enum RequestType {
  create('create'),
  update('update'),
  progressTicket('progress_ticket'),
  delete('delete'),
  move('move'),
  assign('assign'),
  updateAcl('update_acl');

  const RequestType(this.jsonValue);

  /// The JSON-serializable string value for this request type.
  final String jsonValue;

  /// Creates a [RequestType] from a JSON string value.
  static RequestType fromJson(String value) =>
      values.firstWhere((e) => e.jsonValue == value);
}
