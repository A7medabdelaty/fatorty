class Pricing {
  final int? id;
  final String bikeType;
  final double pricePerHour;
  final DateTime createdAt;

  Pricing({
    this.id,
    required this.bikeType,
    required this.pricePerHour,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bike_type': bikeType,
      'price_per_hour': pricePerHour,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Pricing.fromMap(Map<String, dynamic> map) {
    return Pricing(
      id: map['id'],
      bikeType: map['bike_type'],
      pricePerHour: map['price_per_hour'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
