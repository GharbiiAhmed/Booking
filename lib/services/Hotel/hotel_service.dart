import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/hotel.dart';


class HotelService {
  final CollectionReference _hotelCollection =
      FirebaseFirestore.instance.collection('hotels');


  // Add a new hotel
  Future<void> addHotel(Hotel hotel) async {
    try {
      await _hotelCollection.add(hotel.toMap());
    } catch (e) {
      throw Exception("Failed to add hotel: $e");
    }
  }

  // Get all hotels
  Future<List<Hotel>> getHotels() async {
    try {
      QuerySnapshot snapshot = await _hotelCollection.get();
      print(snapshot.docs.length);
      return snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception("Failed to load hotels: $e");
    }
  }

  // Update an existing hotel
  Future<void> updateHotel(Hotel hotel) async {
    try {
      await _hotelCollection.doc(hotel.id).update(hotel.toMap());
    } catch (e) {
      throw Exception("Failed to update hotel: $e");
    }
  }

  // Delete a hotel
  Future<void> deleteHotel(String hotelId) async {
    try {
      await _hotelCollection.doc(hotelId).delete();
    } catch (e) {
      throw Exception("Failed to delete hotel: $e");
    }
  }

  // Get a specific hotel by ID
  Future<Hotel?> getHotelById(String hotelId) async {
    try {
      DocumentSnapshot doc = await _hotelCollection.doc(hotelId).get();
      if (doc.exists) {
        return Hotel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Failed to load hotel: $e");
    }
  }
}
