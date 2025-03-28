import 'package:dmart/src/enums/user_type.dart';
import 'package:dmart/src/models/base_response.dart';
import 'package:dmart/src/models/displayname.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/record.dart';
import 'package:dmart/src/models/status.dart';

class LoginRequest {
  String? shortname;
  String? email;
  String? msisdn;
  String password;

  LoginRequest({required this.shortname, required this.password});

  LoginRequest.withEmail({required this.email, required this.password});

  LoginRequest.withMSISDN({required this.msisdn, required this.password});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shortname != null) {
      data['shortname'] = shortname;
    } else if (email != null) {
      data['email'] = email;
    } else if (msisdn != null) {
      data['msisdn'] = msisdn;
    }

    data['password'] = password;

    return data;
  }
}

class LoginResponse extends BaseResponse {
  String? token;
  UserType? type;
  Displayname? displayname;
  Error? error;

  LoginResponse({this.token, required super.status, super.records});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = Status.values.byName(json['status']);
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
      type = UserType.values.byName(attribute.type ?? 'web');
      displayname = attribute.displayname;
    }
  }
}

class LoginAttributes {
  String? accessToken;
  String? type;
  Displayname? displayname;

  LoginAttributes({this.accessToken, this.type, this.displayname});

  LoginAttributes.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    type = json['type'];
    displayname =
        json['displayname'] != null
            ? Displayname.fromJson(json['displayname'])
            : null;
  }
}
