class Description {
  String? en;
  String? ar;
  String? ku;

  Description({this.en, this.ar, this.ku});

  Description.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
    ku = json['ku'];
  }

  /// Converts the Description object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en, 'ku': ku};
  }
}
