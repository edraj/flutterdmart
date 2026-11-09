import 'package:dmart/src/models/displayname.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/request/action_request.dart';

/// The body of `POST /user/create` (`Dmart.createUser`).
class CreateUserRequest {
  late CreateUserAttributes attributes;

  /// The username to register under, or `"auto"` (the default) to let the
  /// server make one. dmart >= 1.7.9 honours a chosen name: it must be free
  /// and pass the server's username rule (see `ClientConfig.usernameHint`
  /// and `Dmart.checkExisting`). Older servers always make one.
  String shortname;

  CreateUserRequest({this.shortname = "auto", required this.attributes});

  /// Converts the CreateUserRequest object to a JSON object.
  Map<String, dynamic> toJson() => {
    'shortname': shortname,
    'attributes': attributes.toJson(),
  };
}

/// What a registrant may set on `POST /user/create`.
///
/// dmart reads `email`, `msisdn`, `password`, the codes, `displayname` and
/// `language` from this class. It also accepts `description`, `tags` and a
/// `payload` on sign-up, which this class does not carry yet; set those
/// afterwards with `Dmart.updateProfile`. A server that allows registration
/// needs a code for each address given ([emailOTP], [msisdnOTP], from
/// `Dmart.otpRequest` with purpose `OtpPurpose.register`). The deprecated fields were never applied
/// by dmart's self-registration and are no longer sent: roles and groups come
/// from the server's defaults, the account is always an active web account,
/// and an address counts as verified only once its code was checked.
class CreateUserAttributes {
  @Deprecated("dmart dropped invitations; no longer sent.")
  String? invitation;
  late Displayname displayname;
  late String? email;
  @Deprecated("Not read by dmart's /user/create; no longer sent.")
  late String? profilePicUrl;
  late String? msisdn;
  late String? password;
  @Deprecated("Self-registration cannot pick roles; no longer sent.")
  late List<String>? roles;
  @Deprecated("Self-registration cannot pick groups; no longer sent.")
  late List<String>? groups;
  @Deprecated("Not read by dmart's /user/create; no longer sent.")
  late String? firebaseToken;
  @Deprecated("Not read by dmart's /user/create; send it on Dmart.login instead. No longer sent.")
  late String? deviceID;
  late String? language;
  @Deprecated("Set by the server once the address's code is checked; no longer sent.")
  late bool? isEmailVerified;
  @Deprecated("Set by the server once the address's code is checked; no longer sent.")
  late bool? isMsisdnVerified;
  @Deprecated("Set by the server; no longer sent.")
  late bool? forcePasswordChange;

  /// The code sent to [msisdn] by `Dmart.otpRequest` with purpose `register`.
  late String? msisdnOTP;

  /// The code sent to [email] by `Dmart.otpRequest` with purpose `register`.
  late String? emailOTP;

  CreateUserAttributes({
    this.invitation,
    required this.displayname,
    this.email,
    this.profilePicUrl,
    this.msisdn,
    this.password,
    this.roles,
    this.groups,
    this.firebaseToken,
    this.deviceID,
    this.language,
    this.isEmailVerified,
    this.isMsisdnVerified,
    this.forcePasswordChange,
    this.msisdnOTP,
    this.emailOTP,
  });

  factory CreateUserAttributes.fromJson(Map<String, dynamic> json) => CreateUserAttributes(
    displayname: Displayname.fromJson(json['displayname']),
    email: json['email'],
    msisdn: json['msisdn'],
    password: json['password'],
    language: json['language'],
    msisdnOTP: json['msisdn_otp'],
    emailOTP: json['email_otp'],
  );

  /// Converts the CreateUserAttributes object to a JSON object.
  Map<String, dynamic> toJson() => {
    'displayname': displayname.toJson(),
    'email': email,
    'msisdn': msisdn,
    'password': password,
    'language': language,
    'msisdn_otp': msisdnOTP,
    'email_otp': emailOTP,
  };
}

class CreateUserResponse {
  late String status;
  late List<ActionRequestRecord> records;
  Error? error;

  CreateUserResponse({required this.status, required this.records, this.error});

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      status: json['status'],
      records: (json['records'] as List).map((e) => ActionRequestRecord.fromJson(e)).toList(),
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
  }

  /// Converts the CreateUserResponse object to a JSON object.
  Map<String, dynamic> toJson() => {'status': status, 'error': error?.toJson()};
}
