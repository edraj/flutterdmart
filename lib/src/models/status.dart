enum Status {
  success,
  failed;

  static Status byName(String name) => Status.values.byName(name);
}
