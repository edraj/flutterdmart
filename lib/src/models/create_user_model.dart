import 'package:dmart/src/models/displayname.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/request/action_request.dart';

class CreateUserRequest {
  late CreateUserAttributes attributes;

  String shortname;

  CreateUserRequest({this.shortname = "auto", required this.attributes});

  /// Converts the CreateUserRequest object to a JSON object.
  Map<String, dynamic> toJson() => {
    'shortname': shortname,
    'subpath': "users",
    'resource_type': "user",
    'attributes': attributes.toJson(),
  };
}

class CreateUserAttributes {
  late String invitation;
  late Displayname displayname;
  late String? email;
  late String? profilePicUrl;
  late String? msisdn;
  late String? password;
  late List<String>? roles;
  late List<String>? groups;
  late String? firebaseToken;
  late String? language;
  late bool? isEmailVerified;
  late bool? isMsisdnVerified;
  late bool? forcePasswordChange;
  late String? msisdnOTP;
  late String? emailOTP;

  CreateUserAttributes({
    required this.invitation,
    required this.displayname,
    this.email,
    this.profilePicUrl,
    this.msisdn,
    this.password,
    this.roles,
    this.groups,
    this.firebaseToken,
    this.language,
    this.isEmailVerified,
    this.isMsisdnVerified,
    this.forcePasswordChange,
    this.msisdnOTP,
    this.emailOTP,
  });

  factory CreateUserAttributes.fromJson(Map<String, dynamic> json) => CreateUserAttributes(
    invitation: json['invitation'],
    displayname: Displayname.fromJson(json['displayname']),
    email: json['email'],
    profilePicUrl: json['profile_pic_url'],
    msisdn: json['msisdn'],
    password: json['password'],
  );

  /// Converts the CreateUserAttributes object to a JSON object.
  Map<String, dynamic> toJson() => {
    'invitation': invitation,
    'displayname': displayname.toJson(),
    'email': email,
    'profile_pic_url': profilePicUrl,
    'msisdn': msisdn,
    'password': password,
    'roles': roles,
    'groups': groups,
    'firebaseToken': firebaseToken,
    'language': language,
    'isEmailVerified': isEmailVerified,
    'isMsisdnVerified': isMsisdnVerified,
    'forcePasswordChange': forcePasswordChange,
    'is_active': true,
    'msisdn_otp': msisdnOTP,
    'email_otp': emailOTP,
  };
}

class CreateUserResponse {
  late String status;
  late ActionRequestRecord records;
  Error? error;

  CreateUserResponse({required this.status, required this.records, this.error});

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    final responseRecord = json['records'] as List<Map<String, dynamic>>;
    return CreateUserResponse(
      status: json['status'],
      records: ActionRequestRecord.fromJson(responseRecord[0]),
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  /// Converts the CreateUserResponse object to a JSON object.
  Map<String, dynamic> toJson() => {'status': status, 'error': error?.toJson()};
}
