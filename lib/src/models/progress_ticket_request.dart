import '../enums/scope.dart';

class ProgressTicketRequest {
  final String spaceName;
  final String subpath;
  final String shortname;
  final String action;
  final String? resolution;
  final String? comment;

  ProgressTicketRequest({
    required this.spaceName,
    required this.subpath,
    required this.shortname,
    required this.action,
    this.resolution,
    this.comment,
  });
  String url(Scope scope) => '/${[scope.name, 'progress-ticket', spaceName, subpath, shortname, action].join('/')}'
      .replaceAll(RegExp(r'/+'), '/');

  /// Converts the request to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'space_name': spaceName,
      'subpath': subpath,
      'shortname': shortname,
      'action': action,
      'resolution': resolution,
      'comment': comment,
    };
  }
}
