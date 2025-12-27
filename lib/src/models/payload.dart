import 'package:dmart/src/enums/content_type.dart';
import 'package:dmart/src/enums/validation_status.dart';

/// Payload is a class that represents the payload of a resource.
class Payload<T> {
  /// The type of content in the payload.
  final ContentType contentType;

  /// The shortname of the schema of the payload.
  final String? schemaShortname;

  /// The checksum of the payload.
  final String? checksum;

  /// The body of the payload.
  final T body;

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

  /// Converts a JSON object to a Payload object.
  factory Payload.fromJson(Map<String, dynamic> json, [T Function(dynamic)? fromJsonT]) {
    return Payload<T>(
      contentType: ContentType.byName(json['content_type']),
      schemaShortname: json['schema_shortname'],
      checksum: json['checksum'],
      body: fromJsonT != null ? fromJsonT(json['body']) : json['body'] as T,
      lastValidated: json['last_validated'],
      validationStatus: json['validation_status'] != null ? ValidationStatus.byName(json['validation_status']) : null,
    );
  }

  /// Converts the Payload object to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'content_type': contentType.name,
      'schema_shortname': schemaShortname,
      'checksum': checksum,
      'body': body is Object && (body as dynamic).toJson != null ? (body as dynamic).toJson() : body,
      'last_validated': lastValidated,
      'validation_status': validationStatus?.name,
    };
  }
}
