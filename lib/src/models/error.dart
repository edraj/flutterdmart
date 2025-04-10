class Error {
  String? type;
  int? code;
  String? message;
  List<Map<String, dynamic>>? info;

  Error({this.type, this.code, this.message, this.info});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      type: json['type'],
      code: json['code'],
      message: json['message'],
      info: json['info']?.cast<Map<String, dynamic>>(),
    );
  }

  /// Converts the Error object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'type': type, 'code': code, 'message': message, 'info': info};
  }
}
