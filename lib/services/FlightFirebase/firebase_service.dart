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
    required String tripType, // One Way or Round Trip
    required String departureDate, // Departure date
    String? returnDate, // Return date for Round Trip (nullable)
  }) async {
    try {
      final flightData = {
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
        'tripType': tripType,
        'departureDate': departureDate,
        'returnDate': tripType == 'Round Trip' ? returnDate : null,
      };

      await _firestore.collection('flights').add(flightData);
    } catch (e) {
      print("Failed to create flight: $e");
    }
  }

  // Stream flights from Firestore for real-time updates
  Stream<List<Map<String, dynamic>>> readFlights() {
    return _firestore.collection('flights').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();
    });
  }

  // Get best offers by max price and layovers
  Future<List<Map<String, dynamic>>> getBestOffers({
    double maxPrice = 100.0,
    int maxLayovers = 1,
  }) async {
    try {
      // Query the flights collection with the max price and max layovers filters
      QuerySnapshot snapshot = await _firestore.collection('flights')
          .where('price', isLessThanOrEqualTo: maxPrice)
          .where('layovers', isLessThanOrEqualTo: maxLayovers)
          .get();

      // Return the flights as a list of maps, including flight ID and image path
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          // Add the document ID to each result
          'imagePath': data['imagePath'] ?? '',
          // Include image URL (if available)
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
      // Query the flights collection based on the origin and destination
      QuerySnapshot snapshot = await _firestore.collection('flights')
          .where('origin', isEqualTo: origin)
          .where('destination', isEqualTo: destination)
          .get();

      // Return the flights as a list of maps, including the flight ID
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id}; // Add the document ID to each result
      }).toList();
    } catch (e) {
      print("Failed to fetch flights by origin and destination: $e");
      return [];
    }
  }


  // Update an existing flight in Firestore
  Future<void> updateFlight(String flightId, {
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
    required String tripType,
    required String departureDate,
    String? returnDate,
  }) async {
    try {
      final flightData = {
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
        'tripType': tripType,
        'departureDate': departureDate,
        'returnDate': tripType == 'Round Trip' ? returnDate : null,
      };

      await _firestore.collection('flights').doc(flightId).update(flightData);
    } catch (e) {
      print("Failed to update flight: $e");
    }
  }

  // Delete an existing flight from Firestore
  Future<void> deleteFlight(String flightId) async {
    try {
      await _firestore.collection('flights').doc(flightId).delete();
    } catch (e) {
      print("Failed to delete flight: $e");
    }
  }

  // Save booking method
  Future<void> saveBooking({
    required String flightId,
    required String userId,
    required String tripType,
    required String departureDate,
    String? returnDate,
    required String name,
    required String passport,
    required String seat,
  }) async {
    try {
      final bookingData = {
        'flightId': flightId,
        'userId': userId,
        'tripType': tripType,
        'departureDate': departureDate,
        'returnDate': returnDate,
        'name': name,
        'passport': passport,
        'seat': seat,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save booking in Firestore
      await _firestore.collection('bookings').add(bookingData);
    } catch (e) {
      print('Error saving booking: $e');
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }

  // Save payment details in Firestore
  Future<void> savePayment({
    required String userId,
    required String flightId,
    required double price,
    required String paymentMethod,
    required String paymentStatus,
    required String tripType,
    required String departure, // Origin
    required String arrival, // Destination
  }) async {
    try {
      final paymentData = {
        'userId': userId,
        'flightId': flightId,
        'price': price,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'tripType': tripType,
        'departure': departure, // Saving departure as origin
        'arrival': arrival, // Saving arrival as destination
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save data to Firestore in the 'payments' collection (or your custom collection)
      await FirebaseFirestore.instance.collection('payments').add(paymentData);
    } catch (e) {
      print("Error saving payment: $e");
    }
  }


}
