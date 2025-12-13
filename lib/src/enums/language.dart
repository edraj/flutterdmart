enum Language {
  arabic,
  english,
  kurdish,
  french,
  turkish;

  static Language byName(String name) => Language.values.byName(name);
}
