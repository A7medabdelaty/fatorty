import 'package:flutter/foundation.dart';

@immutable
class Cashier {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String password;
  final DateTime createdAt;

  Cashier({
    this.id,
    required this.name,
    this.phone,
    this.email,
    required this.password,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Cashier copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return Cashier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Cashier.fromMap(Map<String, dynamic> map) {
    return Cashier(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cashier &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.email == email &&
        other.password == password &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, phone, email, password, createdAt);
  }

  @override
  String toString() {
    return 'Cashier(id: $id, name: $name, phone: $phone, email: $email, createdAt: $createdAt)';
  }

  bool validate() {
    if (name.isEmpty) return false;
    if (password.isEmpty) return false;
    if (email != null &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
      return false;
    }
    if (phone != null && !RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone!)) {
      return false;
    }
    return true;
  }
}
