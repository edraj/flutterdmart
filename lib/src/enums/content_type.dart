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
