enum ActionType {
  query,
  view,
  update,
  create,
  delete,
  attach,
  move,
  progress_ticket,
  assign,
  lock,
  unlock;

  /// The action dmart names [value], or null for one this package doesn't
  /// know yet.
  static ActionType? tryParse(Object? value) => ActionType.values.asNameMap()[value?.toString()];
}
