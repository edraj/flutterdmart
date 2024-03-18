import 'package:dmart/src/enums/content_type.dart';
import 'package:dmart/src/enums/validation_status.dart';

class Payload {
  final ContentType contentType;
  final String? schemaShortname;
  final String? checksum;
  final dynamic body;
  final String? lastValidated;
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
}
