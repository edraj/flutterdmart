/// A model class for the record object
class Record {
  /// The type of resource to perform the action on.
  String? resourceType;

  /// The shortname of the resource.
  String? shortname;

  /// The subpath of the resource.
  String? subpath;

  /// The attributes to perform the action with.
  dynamic attributes;

  Record({this.resourceType, this.shortname, this.subpath});

  Record.fromJson(Map<String, dynamic> json) {
    resourceType = json['resource_type'];
    shortname = json['shortname'];
    subpath = json['subpath'];
    attributes = json['attributes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resource_type'] = resourceType;
    data['shortname'] = shortname;
    data['subpath'] = subpath;
    data['attributes'] = attributes;
    return data;
  }
}
