import 'package:dmart/src/enums/user_type.dart';
import 'package:dmart/src/models/base_response.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/record.dart';
import 'package:dmart/src/models/status.dart';
import 'package:dmart/src/models/translation.dart';

class LoginRequest {
  LoginRequest({required this.shortname, required this.password});

  LoginRequest.withShortnameAndOTP({
    required this.shortname,
    required this.otp,
  });

  LoginRequest.withEmail({required this.email, required this.password});

  LoginRequest.withEmailAndOTP({required this.email, required this.otp});

  LoginRequest.withInvitation({
    required this.shortname,
    required this.invitation,
  });

  LoginRequest.withMSISDN({required this.msisdn, required this.password});

  LoginRequest.withMSISDNAndOTP({required this.msisdn, required this.otp});
  String? shortname;
  String? email;
  String? otp;
  String? invitation;
  String? firebaseToken;
  String? deviceID;
  String? msisdn;
  String? password;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'shortname': shortname,
      'email': email,
      'msisdn': msisdn,
      'firebase_token': firebaseToken,
      'device_id': deviceID,
      'otp': otp,
      'invitation': invitation,
      'password': password,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class LoginResponse extends BaseResponse {
  LoginResponse({this.token, required super.status, super.records});

  /// Converts the LoginResponse object to a JSON map.
  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = Status.values.byName(json['status']);
    if (status == Status.failed) {
      error = DmartError.fromJson(json['error']);
      return;
    }
    if (json['records'] != null && json['records']!.isNotEmpty) {
      records = [];
      final Record record = Record.fromJson(json['records'][0]);
      records?.add(record);
      final LoginAttributes attribute = LoginAttributes.fromJson(
        record.attributes,
      );
      token = attribute.accessToken;
      type = UserType.values.byName(attribute.type ?? 'web');
      displayname = attribute.displayname;
    }
  }
  String? token;
  UserType? type;
  Translation? displayname;
  DmartError? error;

  /// Converts the LoginResponse object to a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status?.name,
      'records': records?.map((record) => record.toJson()).toList(),
    };
  }
}

class LoginAttributes {
  LoginAttributes({this.accessToken, this.type, this.displayname});

  /// Converts the LoginAttributes object to a JSON map.
  LoginAttributes.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    type = json['type'];
    displayname =
        json['displayname'] != null
            ? Translation.fromJson(json['displayname'])
            : null;
  }
  String? accessToken;
  String? type;
  Translation? displayname;

  /// Converts the LoginAttributes object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'type': type,
      'displayname': displayname?.toJson(),
    };
  }
}
