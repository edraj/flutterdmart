class Displayname {
  String? en;
  String? ar;
  String? kd;

  Displayname({this.en, this.ar, this.kd});

  Displayname.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
    kd = json['kd'];
  }

  /// Converts the Displayname object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en, 'kd': kd};
  }
}
