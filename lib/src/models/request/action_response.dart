import 'package:dmart/src/enums/resource_type.dart';
import 'package:dmart/src/models/api_response.dart';
import 'package:dmart/src/models/attributes.dart';
import 'package:dmart/src/models/error.dart';
import 'package:dmart/src/models/query/response_record.dart';
import 'package:dmart/src/models/status.dart';

import '../../dmart.dart';
import '../../enums/scope.dart';

class ActionResponse extends ApiResponse {
  List<ActionResponseRecord>? records;
  Attributes? attributes;

  ActionResponse({required super.status, super.error, this.records, this.attributes});

  factory ActionResponse.fromJson(Map<String, dynamic> json) {
    ActionResponse actionResponse = ActionResponse(
      status: json['status'] == 'success' ? Status.success : Status.failed,
      error: json['error'] != null ? DmartError.fromJson(json['error']) : null,
    );
    if (json['records'] != null) {
      actionResponse.records =
          (json['records'] as List<dynamic>).map((record) => ActionResponseRecord.fromJson(record)).toList();
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

class ActionResponseRecord extends ResponseRecord {
  late final ActionResponseAttachments? attachments;

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
    String baseUrl = Dmart.dio?.options.baseUrl ?? Dmart.config!.baseUrl;

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

    String baseUrl = Dmart.dio?.options.baseUrl ?? Dmart.config!.baseUrl;

    ResponseRecord med = mediaBody.firstWhere((element) => element.shortname == shortname);

    return "$baseUrl/${scope.name}/payload/media/$spaceName/$subpath/$shortname/${med.attributes.payload!.body}";
  }

  factory ActionResponseRecord.fromJson(Map<String, dynamic> json) {
    var actionResponseRecord = ActionResponseRecord(
      resourceType: ResourceType.byName(json['resource_type']),
      uuid: json['uuid'],
      shortname: json['shortname'],
      subpath: json['subpath'],
      attributes: ResponseRecordAttributes.fromJson(json['attributes']),
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
  final List<ResponseRecord>? media;
  final List<ResponseRecord>? json;

  ActionResponseAttachments({required this.media, required this.json});

  List<String> get AttachmentsUrls {
    return [];
  }
  //   extension AttachementExtension on ActionResponseAttachments {
  //   String? getUrl({
  //     required String type,
  //     String scope = "managed",
  //     required String entitySubpath,
  //     required String shortname,
  //   }) {
  //     return "${Dmart.dio?.options.baseUrl}/$scope/payload/media/$type/$entitySubpath/$shortname/${media?.first.attributes.payload?.body}";
  //   }
  // }

  factory ActionResponseAttachments.fromJson(Map<String, dynamic> json) {
    return ActionResponseAttachments(
      media:
          json['media'] != null
              ? (json['media'] as List<dynamic>?)?.map((mediaRecord) => ResponseRecord.fromJson(mediaRecord)).toList()
              : null,
      json:
          json['json'] != null
              ? (json['json'] as List<dynamic>?)?.map((jsonRecord) => ResponseRecord.fromJson(jsonRecord)).toList()
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
