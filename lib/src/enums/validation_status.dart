enum ValidationStatus {
  valid,
  invalid;

  static ValidationStatus byName(String name) => ValidationStatus.values.byName(name);
}
