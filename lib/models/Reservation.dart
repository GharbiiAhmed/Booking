import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String reservationId;
  final String userId;
  final String driverId;
  final String? vehicleId;
  final DateTime reservationDate;
  final String state;
  final String type;
  final String? pickupLocation;
  final String? dropoffLocation;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? pickupTime;

  Reservation({
    required this.reservationId,
    required this.userId,
    required this.driverId,
    this.vehicleId,
    required this.reservationDate,
    required this.state,
    required this.type,
    this.pickupLocation,
    this.dropoffLocation,
    this.startDate,
    this.endDate,
    this.pickupTime,
  });

  factory Reservation.fromMap(Map<String, dynamic> data) {
    return Reservation(
      reservationId: data['reservationId'] ?? FirebaseFirestore.instance.collection('drivers').doc(),
      userId: data['userId'] ?? '',
      driverId: data['driverId'] ?? '', // Allowing null
      vehicleId: data['vehicleId'] as String?, // Allowing null
      reservationDate: (data['reservationDate'] as Timestamp).toDate(),
      state: data['state'] ?? '',
      type: data['type'] ?? '',
      pickupLocation: data['pickupLocation'] as String?, // Allowing null
      dropoffLocation: data['dropoffLocation'] as String?, // Allowing null
      startDate: (data['startDate'] as Timestamp?)?.toDate(), // Nullable
      endDate: (data['endDate'] as Timestamp?)?.toDate(), // Nullable
      pickupTime: data['pickupTime'] as String?, // Allowing null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reservationId': reservationId,
      'userId': userId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'reservationDate': reservationDate,
      'state': state,
      'type': type,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'pickupTime': pickupTime,
    };
  }
}
