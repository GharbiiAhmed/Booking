import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get vehicles => _firestore.collection('Vehicles');

  // Add a new vehicle with error handling
  Future<void> addVehicle(String plateNumber, String type, String driverId, String status, String model) async {
    try {
      await vehicles.add({
        'plateNumber': plateNumber,
        'type': type,
        'driverId': driverId,
        'status': status,
        'model': model,
      });
    } catch (e) {
      print("Error adding vehicle: $e");
    }
  }

  // Delete a vehicle by ID with error handling
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await vehicles.doc(vehicleId).delete();
    } catch (e) {
      print("Error deleting vehicle: $e");
    }
  }

  // Update vehicle details with error handling
  Future<void> updateVehicle(String vehicleId, String plateNumber, String type, String driverId, String status, String model) async {
    try {
      await vehicles.doc(vehicleId).update({
        'plateNumber': plateNumber,
        'type': type,
        'driverId': driverId,
        'status': status,
        'model': model,
      });
    } catch (e) {
      print("Error updating vehicle: $e");
    }
  }

  // Get all vehicles with error handling
  Future<List<Map<String, dynamic>>> getVehicles() async {
    try {
      QuerySnapshot snapshot = await vehicles.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error getting vehicles: $e");
      return [];
    }
  }
}
