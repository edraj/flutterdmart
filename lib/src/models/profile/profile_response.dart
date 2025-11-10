import 'package:dmart/src/enums/language.dart';
import 'package:dmart/src/enums/resource_type.dart';
import 'package:dmart/src/models/api_response.dart';
import 'package:dmart/src/models/displayname.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/profile/permission.dart';
import 'package:dmart/src/models/status.dart';

class ProfileResponse extends ApiResponse {
  List<ProfileResponseRecord>? records;

  ProfileResponse({required Status status, Error? error, this.records})
    : super(status: status, error: error);

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    ProfileResponse profileResponse = ProfileResponse(
      status: json['status'] == 'success' ? Status.success : Status.failed,
      error: json['error'] != null ? Error.fromJson(json['error']) : null,
    );
    if (json['records'] != null) {
      profileResponse.records =
          (json['records'] as List<dynamic>)
              .map((record) => ProfileResponseRecord.fromJson(record))
              .toList();
    }
    return profileResponse;
  }
}

class ProfileResponseRecord {
  String shortname;
  ResourceType resourceType;
  final ProfileResponseRecordAttributes attributes;

  ProfileResponseRecord({
    required this.resourceType,
    required this.shortname,
    required String subpath,
    required this.attributes,
  });

  factory ProfileResponseRecord.fromJson(Map<String, dynamic> json) {
    return ProfileResponseRecord(
      resourceType: ResourceType.values.byName(json['resource_type']),
      shortname: json['shortname'],
      subpath: json['subpath'],
      attributes: ProfileResponseRecordAttributes.fromJson(
        Map<String, dynamic>.from(json['attributes']),
      ),
    );
  }
}

class ProfileResponseRecordAttributes {
  final String? email;
  final String? msisdn;
  final Displayname displayname;
  final String type;
  final String? firebaseToken;
  final Language? language;
  final bool isEmailVerified;
  final bool isMsisdnVerified;
  final bool forcePasswordChange;
  final Map<String, Permission> permissions;
  final Map<String, dynamic>? payload;

  ProfileResponseRecordAttributes({
    this.email,
    this.msisdn,
    this.firebaseToken,
    required this.displayname,
    required this.type,
    this.language,
    required this.isEmailVerified,
    required this.isMsisdnVerified,
    required this.forcePasswordChange,
    required this.permissions,
    this.payload,
  });

  factory ProfileResponseRecordAttributes.fromJson(Map<String, dynamic> json) {
    return ProfileResponseRecordAttributes(
      email: json['email'],
      msisdn: json['msisdn'],
      firebaseToken: json['firebase_token'],
      displayname: Displayname.fromJson(
        Map<String, dynamic>.from(json['displayname']),
      ),
      type: json['type'],
      language: Language.values.byName(json['language']),
      isEmailVerified: json['is_email_verified'],
      isMsisdnVerified: json['is_msisdn_verified'],
      forcePasswordChange: json['force_password_change'],
      payload: json['payload']?['body'],
      permissions: Map<String, Permission>.from(
        json['permissions'].map(
          (key, value) => MapEntry(key, Permission.fromJson(value)),
        ),
      ),
    );
  }

  /// Converts the ProfileResponseRecordAttributes object to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'msisdn': msisdn,
      'firebase_token': firebaseToken,
      'displayname': displayname.toJson(),
      'type': type,
      'language': language.toString(),
      'is_email_verified': isEmailVerified,
      'is_msisdn_verified': isMsisdnVerified,
      'force_password_change': forcePasswordChange,
      'permissions': permissions.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}
