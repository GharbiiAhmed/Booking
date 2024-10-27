import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String reservationId;
  final String userId;
  final String driverId;
  final String vehicleId;
  final DateTime reservationDate;
  final String state;

  Reservation({
    required this.reservationId,
    required this.userId,
    required this.driverId,
    required this.vehicleId,
    required this.reservationDate,
    required this.state
  });

  factory Reservation.fromMap(Map<String, dynamic> data) {
    return Reservation(
      reservationId: data['reservationId'] ?? '',
      userId: data['userId'] ?? '',
      driverId: data['driverId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      reservationDate: (data['reservationDate'] as Timestamp).toDate(),
      state: data['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reservationId': reservationId,
      'userId': userId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'reservationDate': Timestamp.fromDate(reservationDate),
      'state': state,
    };
  }
}