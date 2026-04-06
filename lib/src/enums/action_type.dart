/// The type of action that can be performed on a resource.
enum ActionType {
  query('query'),
  view('view'),
  update('update'),
  create('create'),
  delete('delete'),
  attach('attach'),
  move('move'),
  progressTicket('progress_ticket');

  const ActionType(this.jsonValue);

  /// The JSON-serializable string value for this action type.
  final String jsonValue;

  /// Creates an [ActionType] from a JSON string value.
  static ActionType fromJson(String value) =>
      values.firstWhere((e) => e.jsonValue == value);
}
