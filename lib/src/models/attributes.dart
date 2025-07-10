class Attributes {
  final int returned;
  final int total;

  Attributes({
    required this.returned,
    required this.total,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      returned: json['returned'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'returned': returned,
      'total': total,
    };
  }
}
