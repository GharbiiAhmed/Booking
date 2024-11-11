import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/reservation.dart';

class ReservationService {
  final CollectionReference _reservationCollection =
      FirebaseFirestore.instance.collection('reservations');

  Future<void> createReservation(Reservation reservation) async {
    try {
      await _reservationCollection.add(reservation.toMap());
    } catch (e) {
      throw Exception("Failed to create reservation: $e");
    }
  }

  Future<List<Reservation>> getReservations(String userId) async {
    try {
      QuerySnapshot snapshot = await _reservationCollection.where('userId', isEqualTo: userId).get();
      return snapshot.docs.map((doc) => Reservation.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception("Failed to load reservations: $e");
    }
  }

  Future<void> updateReservation(Reservation reservation) async {
    try {
      await _reservationCollection.doc(reservation.id).update(reservation.toMap());
    } catch (e) {
      throw Exception("Failed to update reservation: $e");
    }
  }

  Future<void> deleteReservation(String reservationId) async {
    try {
      await _reservationCollection.doc(reservationId).delete();
    } catch (e) {
      throw Exception("Failed to delete reservation: $e");
    }
  }

  Future<Reservation?> getReservationById(String reservationId) async {
    try {
      DocumentSnapshot doc = await _reservationCollection.doc(reservationId).get();
      if (doc.exists) {
        return Reservation.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Failed to load reservation: $e");
    }
  }
}
