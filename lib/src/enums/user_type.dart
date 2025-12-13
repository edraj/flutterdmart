enum UserType {
  web,
  mobile,
  bot;

  static UserType byName(String name) => UserType.values.byName(name);
}
