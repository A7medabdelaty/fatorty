import 'package:flutter/material.dart';

class Bike {
  final int? id;
  final String name;
  final String type;
  final String status;
  final double pricePerHour;
  final DateTime createdAt;
  // خصائص اختيارية لبعض الشاشات
  final IconData icon;
  final double? pricePerHalfHour;
  final double? pricePerTwoHours;
  final double? supscriptionPrice;
  final String? description;

  Bike({
    this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.pricePerHour,
    DateTime? createdAt,
    required this.icon,
    this.pricePerHalfHour,
    this.pricePerTwoHours,
    this.supscriptionPrice,
    this.description,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'price_per_hour': pricePerHour,
      'created_at': createdAt.toIso8601String(),
      'icon': icon.codePoint,
      'pricePerHalfHour': pricePerHalfHour,
      'pricePerTwoHours': pricePerTwoHours,
      'supscriptionPrice': supscriptionPrice,
      'description': description,
    };
  }

  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      status: map['status'],
      pricePerHour: map['price_per_hour'] is int
          ? (map['price_per_hour'] as int).toDouble()
          : map['price_per_hour'],
      pricePerTwoHours: map['pricePerTwoHours'] is int
          ? (map['pricePerTwoHours'] as int).toDouble()
          : map['pricePerTwoHours'],
      createdAt: DateTime.parse(map['created_at']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      pricePerHalfHour: map['pricePerHalfHour'] != null
          ? (map['pricePerHalfHour'] is int
              ? (map['pricePerHalfHour'] as int).toDouble()
              : map['pricePerHalfHour'])
          : null,
      supscriptionPrice: map['supscriptionPrice'] != null
          ? (map['supscriptionPrice'] is int
              ? (map['supscriptionPrice'] as int).toDouble()
              : map['supscriptionPrice'])
          : null,
      description: map['description'],
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Bike.fromJson(Map<String, dynamic> json) => Bike.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bike &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
