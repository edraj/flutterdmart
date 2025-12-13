import 'package:dmart/src/enums/user_type.dart';
import 'package:dmart/src/models/base_response.dart';
import 'package:dmart/src/models/displayname.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/record.dart';
import 'package:dmart/src/models/status.dart';

class LoginRequest {
  String? shortname;
  String? email;
  String? otp;
  String? invitation;
  String? firebaseToken;
  String? msisdn;
  String? password;

  LoginRequest({required this.shortname, required this.password});

  LoginRequest.withShortnameAndOTP({required this.shortname, required this.otp});

  LoginRequest.withEmail({required this.email, required this.password});

  LoginRequest.withEmailAndOTP({required this.email, required this.otp});

  LoginRequest.withInvitation({required this.shortname, required this.invitation});

  LoginRequest.withMSISDN({required this.msisdn, required this.password});

  LoginRequest.withMSISDNAndOTP({required this.msisdn, required this.otp});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'shortname': shortname,
      'email': email,
      'msisdn': msisdn,
      'firebase_token': firebaseToken,
      'otp': otp,
      'invitation': invitation,
      'password': password,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class LoginResponse extends BaseResponse {
  String? token;
  UserType? type;
  Displayname? displayname;
  Error? error;

  LoginResponse({this.token, required super.status, super.records});

  /// Converts the LoginResponse object to a JSON map.
  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = Status.byName(json['status']);
    if (status == Status.failed) {
      error = Error.fromJson(json['error']);
      return;
    }
    if (json['records'] != null && json['records']!.isNotEmpty) {
      records = [];
      Record? record = Record.fromJson(json['records'][0]);
      records?.add(record);
      LoginAttributes? attribute = LoginAttributes.fromJson(record.attributes);
      token = attribute.accessToken;
      type = UserType.byName(attribute.type ?? 'web');
      displayname = attribute.displayname;
    }
  }

  /// Converts the LoginResponse object to a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return {'status': status?.name, 'records': records?.map((record) => record.toJson()).toList()};
  }
}

class LoginAttributes {
  String? accessToken;
  String? type;
  Displayname? displayname;

  LoginAttributes({this.accessToken, this.type, this.displayname});

  /// Converts the LoginAttributes object to a JSON map.
  LoginAttributes.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    type = json['type'];
    displayname = json['displayname'] != null ? Displayname.fromJson(json['displayname']) : null;
  }

  /// Converts the LoginAttributes object to a JSON map.
  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'type': type, 'displayname': displayname?.toJson()};
  }
}
