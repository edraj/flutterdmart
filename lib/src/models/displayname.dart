class Displayname {
  String? en;
  String? ar;
  String? ku;

  Displayname({this.en, this.ar, this.ku});

  Displayname.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
    ku = json['ku'];
  }

  /// Converts the Displayname object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en, 'ku': ku};
  }
}
