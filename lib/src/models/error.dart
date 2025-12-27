class DmartError {
  String? type;
  int? code;
  String? message;
  List<Map<String, dynamic>>? info;

  DmartError({this.type, this.code, this.message, this.info});

  factory DmartError.fromJson(Map<String, dynamic> json) {
    return DmartError(
      type: json['type'],
      code: json['code'],
      message: json['message'],
      info: json['info']?.cast<Map<String, dynamic>>(),
    );
  }

  /// Converts the DmartError object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'type': type, 'code': code, 'message': message, 'info': info};
  }
}
