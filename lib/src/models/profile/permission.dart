import 'package:dmart/src/enums/action_type.dart';

/// Permission is a class that represents the permissions of a user on a resource.
class Permission {
  /// The actions allowed on the resource.
  final List<ActionType> allowedActions;

  /// The conditions to check for the permissions.
  final List<String>? conditions;

  /// The fields restricted by the permissions.
  final List<dynamic>? restrictedFields;

  /// The values allowed for the fields.
  final Map<String, dynamic>? allowedFieldsValues;

  Permission({
    required this.allowedActions,
    this.conditions,
    this.restrictedFields,
    this.allowedFieldsValues,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      allowedActions:
          (json['allowed_actions'] as List<dynamic>)
              .map((action) => ActionType.values.byName(action.toString()))
              .toList(),
      conditions:
          (json['conditions'] as List<dynamic>?)
              ?.map((condition) => condition.toString())
              .toList(),
      restrictedFields: json['restricted_fields'],
      allowedFieldsValues: json['allowed_fields_values'],
    );
  }

  /// Reads a permission map, keyed `"space:subpath:resource_type"`, as dmart
  /// sends it from `/user/permissions` and the profile. Absent is empty.
  static Map<String, Permission> mapFromJson(Object? json) {
    if (json is! Map) return {};
    return json.map((key, value) => MapEntry(key.toString(), Permission.fromJson(Map<String, dynamic>.from(value))));
  }

  /// Converts the Permission object to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'allowed_actions': allowedActions.map((type) => type.toString().split('.').last).toList(),
      'conditions': conditions,
      'restricted_fields': restrictedFields,
      'allowed_fields_values': allowedFieldsValues,
    };
  }
}
