enum RequestType {
  create,
  update,
  replace,
  delete,
  move,
  assign,
  update_acl;

  static RequestType byName(String name) => RequestType.values.byName(name);
}
