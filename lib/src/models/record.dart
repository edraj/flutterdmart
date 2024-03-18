class Record {
  String? resourceType;
  String? shortname;
  String? branchName;
  String? subpath;
  dynamic attributes;

  Record({this.resourceType, this.shortname, this.branchName, this.subpath});

  Record.fromJson(Map<String, dynamic> json) {
    resourceType = json['resource_type'];
    shortname = json['shortname'];
    branchName = json['branch_name'];
    subpath = json['subpath'];
    attributes = json['attributes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resource_type'] = resourceType;
    data['shortname'] = shortname;
    data['branch_name'] = branchName;
    data['subpath'] = subpath;
    data['attributes'] = attributes;
    return data;
  }
}
