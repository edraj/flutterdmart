class Description {
  String? en;
  String? ar;
  String? kd;

  Description({this.en, this.ar, this.kd});

  Description.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
    kd = json['kd'];
  }

  /// Converts the Description object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en, 'kd': kd};
  }
}
