/// Supported content types for Dmart resources and attachments.
enum ContentType {
  text,
  html,
  markdown,
  json,
  image,
  imageJpeg,
  imagePng,
  imageWebp,
  imageGif,
  imageSVG,
  python,
  pdf,
  audio,
  video,
  jsonl,
  csv,
  sqlite,
  parquet,
  apk;

  /// Returns the MIME type string for this content type.
  String get mediaType => switch (this) {
    ContentType.imageSVG => 'image/svg+xml',
    ContentType.imageJpeg => 'image/jpeg',
    ContentType.imagePng => 'image/png',
    ContentType.imageGif => 'image/gif',
    ContentType.imageWebp => 'image/webp',
    ContentType.image => 'image/*',
    ContentType.text => 'text/*',
    ContentType.html => 'text/html',
    ContentType.markdown => 'text/markdown',
    ContentType.json => 'application/json',
    ContentType.python => 'application/*',
    ContentType.pdf => 'application/pdf',
    ContentType.audio => 'audio/*',
    ContentType.video => 'video/*',
    ContentType.jsonl => 'application/octet-stream',
    ContentType.csv => 'text/csv',
    ContentType.sqlite => 'application/octet-stream',
    ContentType.parquet => 'application/octet-stream',
    ContentType.apk => 'application/vnd.android.package-archive',
  };

  /// Parses a content type string, handling snake_case image variants.
  static ContentType parse(String value) => switch (value) {
    'image_jpeg' || 'image_jpg' => ContentType.imageJpeg,
    'image_png' => ContentType.imagePng,
    'image_svg' => ContentType.imageSVG,
    'image_webp' => ContentType.imageWebp,
    'image_gif' => ContentType.imageGif,
    'image' => ContentType.image,
    _ => ContentType.values.byName(value),
  };
}
