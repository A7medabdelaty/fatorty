import 'bike.dart';
import 'customer.dart';

class Rental {
  final String id;
  final Customer customer;
  final Bike bike;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalCost;
  final String? receiptNumber;

  const Rental({
    required this.id,
    required this.customer,
    required this.bike,
    required this.startTime,
    this.endTime,
    required this.totalCost,
    this.receiptNumber,
  });

  bool get isActive => endTime == null;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Rental copyWith({
    String? id,
    Customer? customer,
    Bike? bike,
    DateTime? startTime,
    DateTime? endTime,
    double? totalCost,
    String? receiptNumber,
  }) {
    return Rental(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      bike: bike ?? this.bike,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCost: totalCost ?? this.totalCost,
      receiptNumber: receiptNumber ?? this.receiptNumber,
    );
  }
}
