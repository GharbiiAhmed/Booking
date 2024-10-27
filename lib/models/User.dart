import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
