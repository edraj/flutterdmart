class Attributes {
  final int returned;
  final int total;

  /// True when [total] is the server's cap (`QUERY_TOTAL_CAP`) rather than
  /// the exact count: there are at least [total] matches. Page by
  /// [returned] rather than [total] when it is set.
  final bool totalIsLowerBound;

  Attributes({
    required this.returned,
    required this.total,
    this.totalIsLowerBound = false,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      returned: json['returned'],
      total: json['total'],
      totalIsLowerBound: json['total_is_lower_bound'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'returned': returned,
      'total': total,
      if (totalIsLowerBound) 'total_is_lower_bound': true,
    };
  }
}
