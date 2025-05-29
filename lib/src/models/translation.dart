class Translation {
  final String? ar;
  final String? en;
  final String? ku;

  Translation({this.ar, this.en, this.ku});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(ar: json['ar'], en: json['en'], ku: json['ku']);
  }
  /// Converts the request to a JSON object.
  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en, 'ku': ku};
  }
}
