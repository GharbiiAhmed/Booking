import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_reservation/models/Reservation.dart';

class OngoingReservationsScreen extends StatefulWidget {
  const OngoingReservationsScreen({super.key});

  @override
  _OngoingReservationsScreenState createState() => _OngoingReservationsScreenState();
}

class _OngoingReservationsScreenState extends State<OngoingReservationsScreen> {
  // Static user ID for filtering reservations
  final String userId = 'static_user_id';  // Replace with the actual userId

  // Method to cancel a reservation in Firestore
  Future<void> _cancelReservation(String reservationId) async {
    await FirebaseFirestore.instance.collection('Reservations').doc(reservationId).update({
      'state': 'Canceled',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation canceled successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Reservations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reservations')
            .where('userId', isEqualTo: userId)  // Filter by specific user
            .where('state', isEqualTo: 'Ongoing')  // Filter ongoing reservations
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No ongoing reservations.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final reservations = snapshot.data!.docs
              .map((doc) => Reservation.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.local_taxi, color: Colors.blueAccent),
                    title: Text(
                      'Reservation with driver ${reservation.driverId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: ${reservation.reservationDate.toLocal().toString().split(' ')[0]} at ${reservation.reservationDate.toLocal().toString().split(' ')[1]}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _cancelReservation(reservation.reservationId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('Cancel'),
                    ),
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
