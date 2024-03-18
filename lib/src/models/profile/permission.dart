import 'package:dmart/src/enums/action_type.dart';

class Permission {
  final List<ActionType> allowedActions;
  final List<String> conditions;
  final List<dynamic> restrictedFields;
  final Map<String, dynamic>? allowedFieldsValues;

  Permission({
    required this.allowedActions,
    required this.conditions,
    required this.restrictedFields,
    this.allowedFieldsValues,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      allowedActions: (json['allowed_actions'] as List<dynamic>)
          .map((action) => ActionType.values.byName(action.toString()))
          .toList(),
      conditions: (json['conditions'] as List<dynamic>)
          .map((condition) => condition.toString())
          .toList(),
      restrictedFields: json['restricted_fields'],
      allowedFieldsValues: json['allowed_fields_values'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowed_actions': allowedActions,
      'conditions': conditions,
      'restricted_fields': restrictedFields,
      'allowed_fields_values': allowedFieldsValues,
    };
  }
}
