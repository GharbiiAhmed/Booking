import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_reservation/models/Reservation.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  // Static user ID for filtering reservations
  final String userId = '1';  // Replace with the actual userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Reservations')
              .where('userId', isEqualTo: userId)  // Filter by specific user
              .where('state', isEqualTo: 'Completed')  // Filter completed reservations
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No completed rides.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final completedReservations = snapshot.data!.docs
                .map((doc) => Reservation.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

            return ListView.builder(
              itemCount: completedReservations.length,
              itemBuilder: (context, index) {
                final reservation = completedReservations[index];
                return ListTile(
                  leading: const Icon(Icons.local_taxi, color: Colors.blueAccent),
                  title: Text('Pick-up: ${reservation.driverId}'),
                  subtitle: Text('Drop-off: ${reservation.vehicleId}'),
                  trailing: const Text('Completed', style: TextStyle(color: Colors.green)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
