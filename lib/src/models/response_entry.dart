import 'package:dmart/src/models/meta_extended.dart';
import 'package:dmart/src/models/payload.dart';
import 'package:dmart/src/models/translation.dart';

class ResponseEntry extends MetaExtended {
  final String? uuid;
  final String? shortname;
  final String? subpath;
  final bool? isActive;
  Translation? displayname;
  Translation? description;
  final Set<String>? tags;
  final String? createdAt;
  final String? updatedAt;
  final String? ownerShortname;
  final Payload? payload;
  final Map<String, dynamic>? attachments;

  ResponseEntry({
    String? email,
    String? msisdn,
    bool? isEmailVerified,
    bool? isMsisdnVerified,
    bool? forcePasswordChange,
    String? password,
    bool? isOpen,
    String? workflowShortname,
    String? state,
    required this.uuid,
    required this.shortname,
    required this.subpath,
    required this.isActive,
    this.displayname,
    this.description,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerShortname,
    this.payload,
    this.attachments,
  }) : super(
          email: email,
          msisdn: msisdn,
          isEmailVerified: isEmailVerified,
          isMsisdnVerified: isMsisdnVerified,
          forcePasswordChange: forcePasswordChange,
          password: password,
          workflowShortname: workflowShortname,
          state: state,
          isOpen: isOpen,
        );

  factory ResponseEntry.fromJson(Map<String, dynamic> json) {
    ResponseEntry responseEntry = ResponseEntry(
      email: json['email'],
      msisdn: json['msisdn'],
      isEmailVerified: json['is_email_verified'],
      isMsisdnVerified: json['is_msisdn_verified'],
      forcePasswordChange: json['force_password_change'],
      password: json['password'],
      workflowShortname: json['workflow_shortname'],
      state: json['state'],
      isOpen: json['is_open'],
      uuid: json['uuid'],
      shortname: json['shortname'],
      subpath: json['subpath'],
      isActive: json['is_active'],
      tags: Set<String>.from(json['tags'] ?? []),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      ownerShortname: json['owner_shortname'],
      payload: json['payload'] != null
          ? Payload.fromJson(Map<String, dynamic>.from(json['payload']))
          : null,
      attachments: json['attachments'] != null
          ? Map<String, dynamic>.from(json['attachments'])
          : null,
    );

    if (json['displayname'] != null) {
      responseEntry.displayname = Translation.fromJson(
        Map<String, dynamic>.from(json['displayname']),
      );
    }
    if (json['description'] != null) {
      responseEntry.description = Translation.fromJson(
        Map<String, dynamic>.from(json['description']),
      );
    }

    return responseEntry;
  }
}
