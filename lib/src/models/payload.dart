import 'package:dmart/src/enums/content_type.dart';
import 'package:dmart/src/enums/validation_status.dart';

/// Payload is a class that represents the payload of a resource.
class Payload {
  /// The type of content in the payload.
  final ContentType contentType;
  /// The shortname of the schema of the payload.
  final String? schemaShortname;
  /// The checksum of the payload.
  final String? checksum;
  /// The body of the payload.
  final dynamic body;
  /// The date the payload was last validated.
  final String? lastValidated;
  /// The status of the validation of the payload.
  ValidationStatus? validationStatus;

  Payload({
    required this.contentType,
    this.schemaShortname,
    required this.checksum,
    required this.body,
    required this.lastValidated,
    this.validationStatus,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    Payload payload = Payload(
      contentType: ContentType.values.byName(json['content_type']),
      schemaShortname: json['schema_shortname'],
      checksum: json['checksum'],
      body: json['body'],
      lastValidated: json['last_validated'],
    );
    if (json['validation_status'] != null) {
      payload.validationStatus = ValidationStatus.values.byName(
        json['validation_status'],
      );
    }

    return payload;
  }

  Map<String, dynamic> toJson() {
    return {
      'content_type': contentType.name,
      'schema_shortname': schemaShortname,
      'checksum': checksum,
      'body': body,
      'last_validated': lastValidated,
      'validation_status': validationStatus?.name,
    };
  }
}
