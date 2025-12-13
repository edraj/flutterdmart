enum ActionType {
  query,
  view,
  update,
  create,
  delete,
  attach,
  move,
  progressTicket;

  static ActionType byName(String name) => ActionType.values.byName(name);
}
