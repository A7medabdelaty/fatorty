class Invoice {
  final int? id;
  final int cashierId;
  final int bikeId;
  final int customerId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? totalHours;
  final double? totalAmount;
  final String status;
  final DateTime createdAt;

  Invoice({
    this.id,
    required this.cashierId,
    required this.bikeId,
    required this.customerId,
    required this.startTime,
    this.endTime,
    this.totalHours,
    this.totalAmount,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cashier_id': cashierId,
      'bike_id': bikeId,
      'customer_id': customerId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_hours': totalHours,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      cashierId: map['cashier_id'],
      bikeId: map['bike_id'],
      customerId: map['customer_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      totalHours: map['total_hours'],
      totalAmount: map['total_amount'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  bool isLateDelivery() {
    if (status == 'مكتمل') return false;
    //if (endTime != null) return false;

    if (totalHours != null) {
      final expectedEndTime = startTime.add(Duration(minutes: totalHours!));
      return DateTime.now().isAfter(expectedEndTime);
    }

    const defaultDuration = Duration(minutes: 30);
    final expectedEndTime = startTime.add(defaultDuration);
    return DateTime.now().isAfter(expectedEndTime);
  }
}
