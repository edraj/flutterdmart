class Attributes {
  Attributes({required this.returned, required this.total});

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(returned: json['returned'], total: json['total']);
  }
  final int returned;
  final int total;

  Map<String, dynamic> toJson() {
    return {'returned': returned, 'total': total};
  }
}
