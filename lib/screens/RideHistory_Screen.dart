import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_reservation/models/Reservation.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  final String userId = '1';

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
              .collection('reservations')
              .where('userId', isEqualTo: userId)
              .where('state', isEqualTo: 'Completed')
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

                String title;
                String subtitle;

                if (reservation.type == 'Taxi') {
                  title = 'Reservation: ${reservation.reservationId ?? 'N/A'}';
                  subtitle = 'Pick-up: ${reservation.pickupLocation ?? 'N/A'}\nDrop-off: ${reservation.dropoffLocation ?? 'N/A'}\nDate: ${reservation.reservationDate}';
                } else if (reservation.type == 'Personal Vehicle' && reservation.driverId == '') {
                  title = 'Reservation: ${reservation.reservationId ?? 'N/A'}';
                  subtitle = 'Vehicle Plate: ${reservation.vehicleId ?? 'N/A'}\nStart: ${reservation.startDate ?? 'N/A'}\nEnd: ${reservation.endDate ?? 'N/A'}\nDate: ${reservation.reservationDate}';
                } else if (reservation.type == 'Personal Vehicle' && reservation.driverId != '') {
                  title = 'Reservation: ${reservation.reservationId ?? 'N/A'}';
                  subtitle = 'Driver Name: ${reservation.driverId}\nStart: ${reservation.startDate ?? 'N/A'}\nEnd: ${reservation.endDate ?? 'N/A'}\nDate: ${reservation.reservationDate}';
                } else {
                  title = 'Unknown Reservation';
                  subtitle = 'No details available';
                }

                return ListTile(
                  leading: const Icon(Icons.local_taxi, color: Colors.blueAccent),
                  title: Text(title),
                  subtitle: Text(subtitle),
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
