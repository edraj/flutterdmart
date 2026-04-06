/// Represents an error returned by the Dmart API.
class DmartError {
  final String? type;
  final int? code;
  final String? message;
  final List<Map<String, dynamic>>? info;

  const DmartError({this.type, this.code, this.message, this.info});

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
