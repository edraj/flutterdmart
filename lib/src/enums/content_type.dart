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
  apk,

  /// A file of no more specific kind: what dmart >= 1.5.6 records for an
  /// upload of an unknown or `application/octet-stream` type.
  binary;

  static ContentType get(String value) {
    return switch (value) {
      "image_jpeg" || "image_jpg" => ContentType.imageJpeg,
      "image_png" => ContentType.imagePng,
      "image_svg" => ContentType.imageSVG,
      "image_webp" => ContentType.imageWebp,
      "image_gif" => ContentType.imageGif,
      "image" => ContentType.image,
      _ => ContentType.values.byName(value),
    };
  }
}
