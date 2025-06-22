class JobType {
  final int id;
  final String name;
  final String baselinePrice;

  JobType({
    required this.id,
    required this.name,
    required this.baselinePrice,
  });

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(
      id: json['id'] ?? 0,
      name: json['name'],
      baselinePrice: json['baseline_price']?.toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseline_price': baselinePrice,
    };
  }
} 