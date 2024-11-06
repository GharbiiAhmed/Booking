import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Driver.dart';
import 'ModifyDriverScreen.dart';

class AllDriversScreen extends StatelessWidget {
  const AllDriversScreen({super.key});

  Future<List<Driver>> _fetchDrivers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Drivers').get();
    return querySnapshot.docs.map((doc) => Driver.fromMap(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Drivers'),
      ),
      body: FutureBuilder<List<Driver>>(
        future: _fetchDrivers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading drivers'));
          }
          final drivers = snapshot.data!;
          if (drivers.isEmpty) {
            return const Center(child: Text('No drivers available'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 3 / 4,
            ),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModifyDriverScreen(driver: driver),
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
                        child: driver.profileImageUrl.isNotEmpty
                            ? Image.asset(driver.profileImageUrl, fit: BoxFit.cover)
                            : Icon(Icons.person, size: 80, color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        driver.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        driver.licenseNumber,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Status: ${driver.status}',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
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
