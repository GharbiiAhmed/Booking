import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_reservation/models/Vehicle.dart';
import 'ModifyVehicleScreen.dart';

class AllVehiculesScreen extends StatefulWidget {
  const AllVehiculesScreen({super.key});

  @override
  _AllVehiculesScreenState createState() => _AllVehiculesScreenState();
}

class _AllVehiculesScreenState extends State<AllVehiculesScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
    _searchController.addListener(_filterVehicles);
  }

  Future<void> _fetchVehicles() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Vehicles').get();
    final vehicles = querySnapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();
    setState(() {
      _allVehicles = vehicles;
      _filteredVehicles = vehicles;
    });
  }

  void _filterVehicles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVehicles = _allVehicles.where((vehicle) {
        return vehicle.plateNumber.toLowerCase().contains(query) ||
            vehicle.model.toLowerCase().contains(query) ||
            vehicle.type.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Vehicles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vehicles...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: _filteredVehicles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 3 / 4,
            ),
            itemCount: _filteredVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = _filteredVehicles[index];
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
                        child: vehicle.imageUrl.isNotEmpty
                            ? Image.asset(vehicle.imageUrl, fit: BoxFit.cover)
                            : Icon(Icons.directions_car, size: 80, color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        vehicle.plateNumber,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        vehicle.model,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Type: ${vehicle.type}',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Status: ${vehicle.status}',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
