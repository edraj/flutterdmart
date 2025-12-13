enum SortyType {
  ascending,
  descending;

  static SortyType byName(String name) => SortyType.values.byName(name);
}
