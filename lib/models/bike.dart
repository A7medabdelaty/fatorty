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
  final double? hourlyRate;
  final double? price;
  final String? description;

  Bike({
    this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.pricePerHour,
    DateTime? createdAt,
    required this.icon,
    this.hourlyRate,
    this.price,
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
      'hourlyRate': hourlyRate,
      'price': price,
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
      createdAt: DateTime.parse(map['created_at']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      hourlyRate: map['hourlyRate'] != null
          ? (map['hourlyRate'] is int
              ? (map['hourlyRate'] as int).toDouble()
              : map['hourlyRate'])
          : null,
      price: map['price'] != null
          ? (map['price'] is int
              ? (map['price'] as int).toDouble()
              : map['price'])
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
