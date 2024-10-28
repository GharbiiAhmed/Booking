import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_reservation/models/Vehicle.dart';
import 'ModifyVehicleScreen.dart'; // Create this screen for modification

class AllVehiculesScreen extends StatelessWidget {
  const AllVehiculesScreen({super.key});

  Future<List<Vehicle>> _fetchVehicles() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Vehicles').get();
    return querySnapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Vehicles'),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _fetchVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading vehicles'));
          }
          final vehicles = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 3 / 4,
            ),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModifyVehicleScreen(vehicle: vehicle),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: vehicle.imageUrl != null
                            ? Image.network(vehicle.imageUrl, fit: BoxFit.cover)
                            : Icon(Icons.directions_car, size: 80, color: Colors.grey),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        vehicle.plateNumber,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
