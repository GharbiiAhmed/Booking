import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get reservations => _firestore.collection('Reservations');

  // Add a new reservation
  Future<void> addReservation(String userId, String driverId, String vehicleId,
      DateTime reservationDate) async {
    await reservations.add({
      'userId': userId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'reservationDate': Timestamp.fromDate(reservationDate),
    });
  }

  // Delete a reservation by ID
  Future<void> deleteReservation(String reservationId) async {
    await reservations.doc(reservationId).delete();
  }

  // Update reservation details
  Future<void> updateReservation(String reservationId, String userId,
      String driverId, String vehicleId, DateTime reservationDate) async {
    await reservations.doc(reservationId).update({
      'userId': userId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'reservationDate': Timestamp.fromDate(reservationDate),
    });
  }

  // Get all reservations
  Future<List<Map<String, dynamic>>> getReservations() async {
    QuerySnapshot snapshot = await reservations.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Get all reservations with userId and status
  Future<List<Map<String, dynamic>>> getReservationsWithUserIdAndStatus(
      String userId, String status) async {
    QuerySnapshot snapshot = await reservations
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}