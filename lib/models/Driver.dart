import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String driverId;
  final String name;
  final String licenseNumber;
  final String status;
  final String vehicleId;

  Driver({
    required this.driverId,
    required this.name,
    required this.licenseNumber,
    required this.status,
    required this.vehicleId,
  });

  factory Driver.fromMap(Map<String, dynamic> data) {
    return Driver(
      driverId: data['driverId'] ?? '',
      name: data['name'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      status: data['status'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'name': name,
      'licenseNumber': licenseNumber,
      'status': status,
      'vehicleId': vehicleId,
    };
  }
}