extension MapExtension on Map<String, dynamic> {
  Map<String, dynamic> withoutNulls() {
    final map = this;
    final newMap = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final nested = value.withoutNulls();
        if (nested.isNotEmpty) newMap[key] = nested;
      } else if (value != null) {
        newMap[key] = value;
      }
    });
    return newMap;
  }
}
