import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new flight with Cloudinary image URL
  Future<void> createFlight({
    required String flightNumber,
    required double price,
    required int duration,
    required int layovers,
    required String airline,
    required int baggageAllowance,
    required double extraBaggageFee,
    required String imagePath, // Cloudinary URL for image
    required String origin,
    required String destination,
  }) async {
    try {
      await _firestore.collection('flights').add({
        'flightNumber': flightNumber,
        'price': price,
        'duration': duration,
        'layovers': layovers,
        'airline': airline,
        'baggageAllowance': baggageAllowance,
        'extraBaggageFee': extraBaggageFee,
        'imagePath': imagePath, // Cloudinary URL stored here
        'origin': origin,
        'destination': destination,
      });
    } catch (e) {
      print("Failed to create flight: $e");
    }
  }

  // Stream flights from Firestore for real-time updates
  Stream<List<Map<String, dynamic>>> readFlights() {
    return _firestore.collection('flights').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id}; // Include document ID
      }).toList();
    });
  }

  // Update an existing flight in Firestore
  Future<void> updateFlight(
      String flightId, {
        required String flightNumber,
        required double price,
        required int duration,
        required int layovers,
        required String airline,
        required int baggageAllowance,
        required double extraBaggageFee,
        required String imagePath,
        required String origin,
        required String destination,
      }) async {
    try {
      await _firestore.collection('flights').doc(flightId).update({
        'flightNumber': flightNumber,
        'price': price,
        'duration': duration,
        'layovers': layovers,
        'airline': airline,
        'baggageAllowance': baggageAllowance,
        'extraBaggageFee': extraBaggageFee,
        'imagePath': imagePath,
        'origin': origin,
        'destination': destination,
      });
    } catch (e) {
      print("Failed to update flight: $e");
    }
  }

  // Delete a flight from Firestore
  Future<void> deleteFlight(String flightId) async {
    try {
      await _firestore.collection('flights').doc(flightId).delete();
    } catch (e) {
      print("Failed to delete flight: $e");
    }
  }

  // Get best offers by max price and layovers
  Future<List<Map<String, dynamic>>> getBestOffers({double maxPrice = 100.0, int maxLayovers = 1}) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('flights')
          .where('price', isLessThanOrEqualTo: maxPrice)
          .where('layovers', isLessThanOrEqualTo: maxLayovers)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'imagePath': data['imagePath'] ?? '', // Ensure 'imagePath' is included in the result
        };
      }).toList();
    } catch (e) {
      print("Failed to get best offers: $e");
      return [];
    }
  }



  // Get flights by origin and destination
  Future<List<Map<String, dynamic>>> readFlightsByOriginAndDestination({
    required String origin,
    required String destination,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('flights')
          .where('origin', isEqualTo: origin)
          .where('destination', isEqualTo: destination)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id}; // Include document ID
      }).toList();
    } catch (e) {
      print("Failed to fetch flights: $e");
      return [];
    }
  }

  // Save booking details in Firestore
  Future<void> saveBooking(Map<String, dynamic> bookingDetails) async {
    try {
      await _firestore.collection('bookings').add(bookingDetails);
    } catch (e) {
      print("Failed to save booking: $e");
    }
  }

  // Save payment details in Firestore
  Future<void> savePayment(Map<String, dynamic> paymentDetails) async {
    try {
      await _firestore.collection('payments').add(paymentDetails);
    } catch (e) {
      print("Failed to save payment: $e");
    }
  }

  // Update the status of a booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('payments').doc(bookingId).update({'status': status});
    } catch (e) {
      print("Failed to update booking status: $e");
    }
  }

  // Create a new reclamation entry
  Future<void> createReclamation({
    required String paymentId,
    required String details,
  }) async {
    try {
      await _firestore.collection('reclamations').add({
        'paymentId': paymentId,
        'details': details,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Failed to create reclamation: $e");
    }
  }

  // Stream reclamations for a specific payment
  Stream<List<Map<String, dynamic>>> readReclamations(String paymentId) {
    return _firestore.collection('reclamations')
        .where('paymentId', isEqualTo: paymentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id}; // Include document ID
      }).toList();
    });
  }

  // Update an existing reclamation entry
  Future<void> updateReclamation(String reclamationId, {
    required String details,
  }) async {
    try {
      await _firestore.collection('reclamations').doc(reclamationId).update({
        'details': details,
      });
    } catch (e) {
      print("Failed to update reclamation: $e");
    }
  }

  // Delete a reclamation entry
  Future<void> deleteReclamation(String reclamationId) async {
    try {
      await _firestore.collection('reclamations').doc(reclamationId).delete();
    } catch (e) {
      print("Failed to delete reclamation: $e");
    }
  }
}
