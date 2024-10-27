import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String vehicleId;
  final String plateNumber;
  final String type;
  final String driverId;
  final String status;
  final String model;

  Vehicle({
    required this.vehicleId,
    required this.plateNumber,
    required this.type,
    required this.driverId,
    required this.status,
    required this.model,
  });

  factory Vehicle.fromMap(Map<String, dynamic> data) {
    return Vehicle(
      vehicleId: data['vehicleId'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      type: data['type'] ?? '',
      driverId: data['driverId'] ?? '',
      status: data['status'] ?? '',
      model: data['model'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'plateNumber': plateNumber,
      'type': type,
      'driverId': driverId,
      'status': status,
      'model': model,
    };
  }
}