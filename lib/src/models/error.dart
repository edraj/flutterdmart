import 'package:dmart/src/models/second_factors.dart';

class Error {
  final String? type;
  final int? code;
  final String? message;
  final List<Map<String, dynamic>>? info;

  const Error({this.type, this.code, this.message, this.info});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      type: json['type'],
      code: json['code'],
      message: json['message'],
      info: json['info']?.cast<Map<String, dynamic>>(),
    );
  }

  /// The second step a sign-in asks for (dmart >= 1.8.1), or null:
  /// `info[0]` of an `OTP_NEEDED` (115) or `SECOND_FACTOR_REQUIRED` (116)
  /// answer for an account with a key or an authenticator app.
  SecondFactorStep? get secondFactor {
    final step = (info != null && info!.isNotEmpty) ? info!.first : null;
    final factors = step?['factors'];
    if (factors is! List) return null;
    final webauthn = step!['webauthn'];
    return SecondFactorStep(
      factors: factors.map((f) => '$f').toList(),
      webauthn: webauthn is Map ? KeyChallenge.fromJson(Map<String, dynamic>.from(webauthn)) : null,
    );
  }

  /// Converts the Error object to a JSON object.
  Map<String, dynamic> toJson() {
    return {'type': type, 'code': code, 'message': message, 'info': info};
  }
}
