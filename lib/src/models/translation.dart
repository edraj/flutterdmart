class Translation {
  final String? ar;
  final String? en;
  final String? kd;

  Translation({this.ar, this.en, this.kd});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(ar: json['ar'], en: json['en'], kd: json['kd']);
  }
  /// Converts the request to a JSON object.
  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en, 'kd': kd};
  }
}
