
import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  final String id; // Unique identifier for the hotel
  final String titleTxt; // Hotel title
  final String subTxt; // Location or subtitle
  final double dist; // Distance from a reference point
  final int reviews; // Number of reviews
  final double rating; // Hotel rating
  final double perNight; // Price per night
  final String imagePath; // Path to the cover image
  final String description; // Description of the hotel
  final List<String> amenities; // List of hotel amenities
  final String contactNumber; // Contact number of the hotel
  final String email; // Email address for inquiries
  final String website; // Hotel's website link
  final double latitude;
  final double longitude;

  Hotel({
    required this.id,
    required this.titleTxt,
    required this.subTxt,
    required this.dist,
    required this.reviews,
    required this.rating,
    required this.perNight,
    required this.imagePath,
    required this.description,
    required this.amenities,
    required this.contactNumber,
    required this.email,
    required this.website,
    required this.latitude,
    required this.longitude,
  });

  // Factory method to create a Hotel instance from a Firestore document
factory Hotel.fromFirestore(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

  return Hotel(
    id: doc.id,
    titleTxt: data['titleTxt']?.toString() ?? '',
    subTxt: data['subTxt']?.toString() ?? '',
    dist: _parseDouble(data['dist']),
    reviews: data['reviews'] is int ? data['reviews'] : int.tryParse(data['reviews']?.toString() ?? '0') ?? 0,
    rating: _parseDouble(data['rating']),
    perNight: _parseDouble(data['perNight']),
    imagePath: data['imagePath']?.toString() ?? '',
    description: data['description']?.toString() ?? '',
    amenities: (data['amenities'] is List)
        ? List<String>.from(data['amenities'] ?? [])
        : <String>[],
    contactNumber: data['contactNumber']?.toString() ?? '',
    email: data['email']?.toString() ?? '',
    website: data['website']?.toString() ?? '',
    latitude: _parseDouble(data['latitude']),
    longitude: _parseDouble(data['longitude']),
  );
}

static double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}


  // Method to convert a Hotel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'titleTxt': titleTxt,
      'subTxt': subTxt,
      'dist': dist,
      'reviews': reviews,
      'rating': rating,
      'perNight': perNight,
      'imagePath': imagePath,
      'description': description,
      'amenities': amenities,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
