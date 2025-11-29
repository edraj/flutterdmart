enum ContentType {
  text,
  html,
  markdown,
  json,
  image,
  python,
  pdf,
  audio,
  video,
  jsonl,
  csv,
  sqlite,
  parquet,
  apk;

  static ContentType byName(String name) => ContentType.values.byName(name);

  String get getMediaType => switch (this) {
    ContentType.image => "image/*",
    ContentType.text => "text/*",
    ContentType.html => "text/html",
    ContentType.markdown => "text/markdown",
    ContentType.json => "application/json",
    ContentType.python => "application/*",
    ContentType.pdf => "application/pdf",
    ContentType.audio => "audio/*",
    ContentType.video => "video/*",
    ContentType.jsonl => "application/octet-stream",
    ContentType.csv => "text/csv",
    ContentType.sqlite => "application/octet-stream",
    ContentType.parquet => "application/octet-stream",
    ContentType.apk => "application/vnd.android.package-archive",
  };
}
