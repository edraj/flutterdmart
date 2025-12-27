import 'package:dmart/src/models/attributes.dart';

import '../../../dmart.dart';
import '../../enums/scope.dart';

class ActionResponse<T> extends ApiResponse {
  List<ActionResponseRecord<T>>? records;
  Attributes? attributes;

  ActionResponse({required super.status, super.error, this.records, this.attributes});

  factory ActionResponse.fromJson(Map<String, dynamic> json, [T Function(dynamic)? fromJsonT]) {
    ActionResponse<T> actionResponse = ActionResponse<T>(
      status: json['status'] == 'success' ? Status.success : Status.failed,
      error: json['error'] != null ? DmartError.fromJson(json['error']) : null,
    );
    if (json['records'] != null) {
      actionResponse.records =
          (json['records'] as List<dynamic>)
              .map((record) => ActionResponseRecord<T>.fromJson(record, fromJsonT))
              .toList();
    }
    if (json['attributes'] != null) {
      actionResponse.attributes = Attributes.fromJson(json['attributes']);
    }

    return actionResponse;
  }

  /// Converts the ActionResponse object to a JSON object.
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status.name;
    if (error != null) {
      data['error'] = error!.toJson();
    }
    if (records != null) {
      data['records'] = records!.map((record) => record.toJson()).toList();
    }
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    return data;
  }
}

class ActionResponseRecord<T> extends ResponseRecord<T> {
  late final ActionResponseAttachments? attachments;

  T? get body {
    return attributes.payload?.body;
  }

  ActionResponseRecord({
    required super.resourceType,
    required super.uuid,
    required super.shortname,
    required super.subpath,
    required super.attributes,
  });

  bool get hasAttachment {
    if (attachments == null) return false;
    if (attachments!.media == null) return false;
    if (attachments!.media!.isEmpty) return false;
    return true;
  }

  List<String> attachmentsUrls({required String spaceName, Scope scope = Scope.public}) {
    final List<ResponseRecord>? mediaBody = attachments?.media;

    if (mediaBody == null) return [];
    List<String> urlList = [];
    String baseUrl = Dmart.dio.options.baseUrl;

    for (var media in mediaBody) {
      String url =
          "$baseUrl/${scope.name}/payload/media/$spaceName/$subpath/$shortname/${media.attributes.payload!.body}";
      urlList.add(url);
    }

    return urlList;
  }

  String? getAttachementByShortname({
    required String shortname,
    required String spaceName,
    Scope scope = Scope.public,
  }) {
    final List<ResponseRecord>? mediaBody = attachments?.media;

    if (mediaBody == null) return null;

    String baseUrl = Dmart.dio.options.baseUrl;

    ResponseRecord med = mediaBody.firstWhere((element) => element.shortname == shortname);

    return "$baseUrl/${scope.name}/payload/media/$spaceName/$subpath/$shortname/${med.attributes.payload!.body}";
  }

  factory ActionResponseRecord.fromJson(Map<String, dynamic> json, [T Function(dynamic)? fromJsonT]) {
    var actionResponseRecord = ActionResponseRecord<T>(
      resourceType: ResourceType.byName(json['resource_type']),
      uuid: json['uuid'],
      shortname: json['shortname'],
      subpath: json['subpath'],
      attributes: ResponseRecordAttributes<T>.fromJson(Map<String, dynamic>.from(json['attributes']), fromJsonT),
    );
    if (json['attachments'] != null) {
      actionResponseRecord.attachments = ActionResponseAttachments.fromJson(json['attachments']);
    }
    return actionResponseRecord;
  }

  /// Converts the ActionResponseRecord object to a JSON object.
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resource_type'] = resourceType.name;
    data['uuid'] = uuid;
    data['shortname'] = shortname;
    data['subpath'] = subpath;
    data['attributes'] = attributes.toJson();
    if (attachments != null) {
      data['attachments'] = attachments!.toJson();
    }
    return data;
  }
}

class ActionResponseAttachments {
  final List<ResponseRecord<dynamic>>? media;
  final List<ResponseRecord<dynamic>>? json;

  ActionResponseAttachments({required this.media, required this.json});

  factory ActionResponseAttachments.fromJson(Map<String, dynamic> json) {
    return ActionResponseAttachments(
      media:
          json['media'] != null
              ? (json['media'] as List<dynamic>?)
                  ?.map((mediaRecord) => ResponseRecord<dynamic>.fromJson(mediaRecord))
                  .toList()
              : null,
      json:
          json['json'] != null
              ? (json['json'] as List<dynamic>?)
                  ?.map((jsonRecord) => ResponseRecord<dynamic>.fromJson(jsonRecord))
                  .toList()
              : null,
    );
  }

  /// Converts the ActionResponseAttachments object to a JSON object.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['media'] = media?.map((record) => record.toJson()).toList();
    data['json'] = json?.map((record) => record.toJson()).toList();
    return data;
  }
}
