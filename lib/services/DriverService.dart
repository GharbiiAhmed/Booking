import 'package:cloud_firestore/cloud_firestore.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get drivers => _firestore.collection('Drivers');

  // Add a new driver with error handling
  Future<void> addDriver(String name, String licenseNumber, String status, String vehicleId) async {
    try {
      await drivers.add({
        'name': name,
        'licenseNumber': licenseNumber,
        'status': status,
        'vehicleId': vehicleId,
      });
    } catch (e) {
      print("Error adding driver: $e");
    }
  }

  // Delete a driver by ID with error handling
  Future<void> deleteDriver(String driverId) async {
    try {
      await drivers.doc(driverId).delete();
    } catch (e) {
      print("Error deleting driver: $e");
    }
  }

  // Update driver details with error handling
  Future<void> updateDriver(String driverId, String name, String licenseNumber, String status, String vehicleId) async {
    try {
      await drivers.doc(driverId).update({
        'name': name,
        'licenseNumber': licenseNumber,
        'status': status,
        'vehicleId': vehicleId,
      });
    } catch (e) {
      print("Error updating driver: $e");
    }
  }

  // Get all drivers with error handling
  Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      QuerySnapshot snapshot = await drivers.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error getting drivers: $e");
      return [];
    }
  }

  // Get drivers by status (e.g., "available" or "unavailable")
  Future<List<Map<String, dynamic>>> getDriversByStatus(String status) async {
    try {
      QuerySnapshot snapshot = await drivers.where('status', isEqualTo: status).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error getting drivers by status: $e");
      return [];
    }
  }

  // Get a single driver by ID
  Future<Map<String, dynamic>?> getDriverById(String driverId) async {
    try {
      DocumentSnapshot doc = await drivers.doc(driverId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error getting driver by ID: $e");
      return null;
    }
  }
}
